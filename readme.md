![Build & tests](https://github.com/nchami-coda/taskops-api-/actions/workflows/ci.yml/badge.svg)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=nchami-coda_taskops-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=nchami-coda_taskops-api)

# TaskOps API

API REST de gestion de tâches — projet fil rouge de la formation
**B3 - DevOps : culture, outils et automatisation**.

## Stack

| Composant | Version |
|-------------|---------|
| Java | 25 (LTS)|
| Spring Boot | 4.1.1 |
| données | H2 (en mémoire) |
| Build | Maven (via `mvnw`) |
| Tests | JUnit 5, Mockito, AssertJ |

## Démarrage rapide

```bash
./mvnw spring-boot:run
curl http://localhost:8080/api/tasks
```

L'API écoute sur `http://localhost:8080`.

## Endpoints

| Méthode | Chemin | Description | Codes |
|---|---|---|---|
| GET | `/api/tasks` | Liste des tâches (`?status=TODO` pour filtrer) | 200 |
| GET | `/api/tasks/{id}` | Une tâche | 200, 404 |
| POST | `/api/tasks` | Créer une tâche | 201, 400 |
| PUT | `/api/tasks/{id}` | Modifier une tâche | 200, 400, 404 |
| DELETE | `/api/tasks/{id}` | Supprimer une tâche | 204, 404 |
| GET | `/api/tasks/stats` | Répartition des tâches par statut | 200 |
| GET | `/api/tasks/tri` | Tri des tâches (piloté par canary) | 200 |
| GET | `/actuator/health` | État de santé de l'application | 200 |
| GET | `/actuator/info` | Métadonnées de build et version | 200 |

## Tests

```bash
./mvnw test
```

## Contribuer

1. Créer une branche depuis `main` : `git switch -c feat/ma-fonctionnalite`
2. Commits au format [Conventional Commits](https://www.conventionalcommits.org/fr/)
3. Ouvrir une Pull Request ; la fusion exige une revue et des tests verts.
