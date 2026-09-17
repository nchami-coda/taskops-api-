# Stratégie de déploiement — TaskOps API

## Artefact

- Un seul artefact par version : `taskops-api-<version>.jar`
- Produit uniquement par le workflow `release.yml`, déclenché par un tag `v*`
- **Jamais reconstruit** entre les environnements (*build once, deploy everywhere*)
- Version lisible à chaud sur `GET /actuator/info`

## Environnements

| Environnement | Déclencheur | Stratégie | Validation |
|---|---|---|---|
| Développement | manuel | recreate | aucune |
| Recette | tag `v*` | rolling | smoke test |
| Production | validation manuelle | blue/green | smoke test + surveillance 15 min |

## Configuration

Toute la configuration passe par des variables d'environnement.
Aucun secret dans le dépôt. Voir `application.properties` pour la liste
des variables et leurs valeurs par défaut de développement.

## Retour arrière

- **Blue/Green** : rollback instantané, le trafic est simplement redirigé
  vers l'instance précédente qui reste démarrée le temps de la validation.
- **Rolling / Recreate** : redéploiement du tag précédent via le même
  workflow de release.

## Livraison progressive (canary applicatif)

Le endpoint `GET /api/tasks/tri` illustre le découplage entre déploiement
et livraison : les deux implémentations du tri cohabitent dans le même
artefact, et la variable d'environnement `CANARY_POURCENTAGE` contrôle
la proportion d'appels qui voient la nouvelle version — sans redéploiement.

⚠️ Un flag de canary est une dette technique temporaire : une fois la
nouvelle implémentation validée à 100 % pendant quelques jours, l'ancienne
implémentation et le flag doivent être supprimés.

## Portes de qualité avant mise en production

1. CI verte (build, tests, couverture) — Module 3
2. Quality Gate SonarCloud passé — Module 3
3. Smoke test post-déploiement réussi — ce module
4. Surveillance manuelle 15 minutes après bascule en production