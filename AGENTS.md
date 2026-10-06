# AGENTS.md

Consignes pour les agents (et les humains) qui modifient ce dépôt.

## Contexte du projet

- Configuration de déploiement de l'intranet : une page statique servie par **Nginx** (`nginx:1.27-alpine`) dans un conteneur Docker.
- Fichiers principaux :
  - `docker-compose.yml` : service `web`, port hôte 8080 → 80, healthcheck ;
  - `nginx/default.conf` : virtual host ;
  - `site/` : contenu publié ;
  - `scripts/` : scripts shell (vérifications, déploiement) ;
  - `docs/adr/` : décisions d'architecture. Le reverse proxy retenu est Traefik (ADR 0001).
- Voir le `README.md` pour l'installation et l'utilisation.

## Commandes de vérification

À lancer avant de proposer un changement ; toutes doivent passer :

```bash
./scripts/check.sh                # compose + nginx -t + shellcheck
docker compose up -d              # démarrage local
docker compose ps                 # le service "web" doit être "healthy"
curl -fsS http://localhost:8080/  # la page doit répondre
```

## Conventions

- Travailler sur une branche : `feature/<sujet>`, `fix/<n° issue>-<sujet>`, `docs/<n° issue>-<sujet>`.
- Commits au format **Conventional Commits** : `type(portée): description` (`feat`, `fix`, `docs`, `chore`, `refactor`…).
- Une **pull request** par changement, avec le modèle de description rempli et `Closes #<n°>` si une issue existe.
- Merge en **Squash and merge**.
- Scripts shell : `#!/usr/bin/env bash` et `set -euo pipefail`, sans avertissement `shellcheck`.
- Images Docker avec une version épinglée (jamais `latest`).
- Documenter toute décision d'architecture dans un nouvel ADR à partir de `docs/adr/0000-modele.md`.

## Interdits

- **Ne jamais pousser directement sur `main`** ni contourner la protection de branche.
- **Ne jamais écrire de secret** (mot de passe, token, clé privée, IP sensible) dans le dépôt : utiliser des variables d'environnement ou un fichier `.env` non versionné.
- Ne pas se connecter en `root` aux serveurs ni lancer de commande sur un serveur de production.
- Ne pas utiliser `chmod 777`, ni désactiver un healthcheck ou une vérification pour faire passer un changement.
- Ne pas supprimer de sauvegarde, ni lancer de commande destructive (`rm -rf`, `docker system prune`, `docker compose down -v`) sans validation humaine.
- Ne pas merger une PR dont les vérifications échouent.
