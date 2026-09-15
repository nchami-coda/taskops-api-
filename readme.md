\# TaskOps API

API REST de gestion de tâches — projet fil rouge de la formation

\*\*B3 - DevOps : culture, outils et automatisation\*\*.

\## Stack

| Composant | Version |

|-------------|---------|

| Java | 25 (LTS)|

| Spring Boot | 4.1.1 |

| données | H2 (en mémoire) |

| Build | Maven (via `mvnw`) |

| Tests | JUnit 5, Mockito, AssertJ |

\## Démarrage rapide

```bash

./mvnw spring-boot:run

curl http://localhost:8080/api/tasks

```

L'API écoute sur `http://localhost:8080`.

\## Endpoints

| Méthode | Chemin | Description | Codes |

|---|---|---|---|

| GET | `/api/tasks` | Liste des tâches (`?status=TODO` pour filtrer) | 200 |

| GET | `/api/tasks/{id}` | Une tâche | 200, 404 |

| POST | `/api/tasks` | Créer une tâche | 201, 400 |

| PUT | `/api/tasks/{id}` | Modifier une tâche | 200, 400, 404 |

| DELETE | `/api/tasks/{id}` | Supprimer une tâche | 204, 404 |

\## Tests

```bash

./mvnw test

```

\## Contribuer

1\. Créer une branche depuis `main` : `git switch -c feat/ma-fonctionnalite`

2\. Commits au format \[Conventional Commits](https://www.conventionalcommits.org/fr/)

3\. Ouvrir une Pull Request ; la fusion exige une revue et des tests verts.

