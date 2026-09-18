# syntax=docker/dockerfile:1

# ══════════════════════════════════════════════════════════════
# ÉTAPE 1 — BUILD : on compile avec le JDK complet.
# Tout ce qui se passe ici sera JETÉ : Maven, les sources, le cache.
# ══════════════════════════════════════════════════════════════

FROM eclipse-temurin:25-jdk-alpine AS build

WORKDIR /build

# 1a. On copie D'ABORD ce qui change RAREMENT : le descripteur de build.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw

# 1b. On telecharge les dependances. Cette couche coûteuse (~2 min)
#     ne sera reconstruite QUE si pom.xml change.
RUN ./mvnw -B dependency:go-offline

# 1c. Puis SEULEMENT ce qui change SOUVENT : le code source.
COPY src/ ./src/

# 1d. Compilation. Le depot Maven local est deja chaud grace a l'etape 1b :
#     seuls quelques plugins manquants seront eventuellement telecharges.
#     On renomme ensuite le JAR en "application.jar" : c'est ce nom que
#     l'extraction conservera, et que l'ENTRYPOINT lancera.
RUN ./mvnw -B clean package -DskipTests \
 && cp target/taskops-api-*.jar application.jar

# 1e. On eclate le JAR en couches ordonnees par frequence de changement.
#     ATTENTION : depuis Spring Boot 4, le mode "layertools" a disparu ;
#     c'est "-Djarmode=tools ... extract --layers" qui le remplace.
RUN java -Djarmode=tools -jar application.jar \
        extract --layers --destination extracted

# ══════════════════════════════════════════════════════════════
# ÉTAPE 2 — RUNTIME : image minimale, JRE seul, aucun outil de build.
# ══════════════════════════════════════════════════════════════
FROM eclipse-temurin:25-jre-alpine AS runtime

# Metadonnees standard OCI : elles voyagent avec l'image
LABEL org.opencontainers.image.title="TaskOps API" \
      org.opencontainers.image.source="https://github.com/nchami-coda/taskops-api-" \
      org.opencontainers.image.licenses="MIT"

# --- Securite : un utilisateur non privilegie ---
# -S : utilisateur/groupe systeme (pas de mot de passe, pas de home)
RUN addgroup -S taskops && adduser -S -G taskops taskops

WORKDIR /application

# --- Les 4 couches, de la plus stable a la plus volatile ---
# Ordre capital : une modification du code ne reconstruit que la derniere.
COPY --from=build --chown=taskops:taskops /build/extracted/dependencies/ ./
COPY --from=build --chown=taskops:taskops /build/extracted/spring-boot-loader/ ./
COPY --from=build --chown=taskops:taskops /build/extracted/snapshot-dependencies/ ./
COPY --from=build --chown=taskops:taskops /build/extracted/application/ ./

USER taskops

EXPOSE 8080

# --- Contrôle de sante interne au conteneur ---
# Docker interroge cette commande : le conteneur passe en "unhealthy"
# si l'application ne repond plus, meme si le processus Java vit encore.
HEALTHCHECK --interval=15s --timeout=3s --start-period=40s --retries=3 \
    CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1

# --- Options JVM adaptees au conteneur ---
# MaxRAMPercentage : la JVM respecte la limite memoire du cgroup
#                    au lieu de croire qu'elle dispose de toute la machine.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"

# On passe par "sh -c" pour que $JAVA_OPTS soit interprete, mais le mot-cle
# "exec" est INDISPENSABLE : il REMPLACE le shell par le processus java,
# qui devient donc PID 1 et reçoit directement le SIGTERM de "docker stop"
# -> arret propre de Spring Boot. Sans "exec", le signal serait capte par
# /bin/sh, l'application ne le verrait jamais et serait tuee brutalement
# apres 10 secondes.
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar application.jar"]