# Intranet services

## Présentation

Ce dépôt contient la configuration de déploiement de l'intranet de l'entreprise : une page web statique servie par Nginx dans un conteneur Docker.

Il sert aussi de base de travail pour l'équipe infra : configuration Docker Compose, configuration Nginx, scripts de vérification et décisions d'architecture (`docs/adr/`).

## Architecture

```
.
├── docker-compose.yml      # définition du service "web" (Nginx)
├── nginx/default.conf      # configuration du virtual host Nginx
├── site/                   # contenu statique publié (index.html)
├── scripts/check.sh        # vérifications avant commit
├── docs/adr/               # Architecture Decision Records
└── .github/                # CODEOWNERS, modèles d'issues et de PR
```

- Un seul service, `web`, basé sur l'image `nginx:1.27-alpine` (conteneur `intranet-web`).
- Le port **8080** de l'hôte est redirigé vers le port 80 du conteneur.
- La configuration Nginx et le contenu du site sont montés en lecture seule.
- Un `healthcheck` interroge `http://localhost/` toutes les 30 secondes ; le conteneur redémarre automatiquement (`restart: unless-stopped`).
- Le choix du reverse proxy placé devant les services est documenté dans [l'ADR 0001](docs/adr/0001-choix-reverse-proxy.md).

## Prérequis

- Docker Engine 24 ou plus récent avec le plugin **Docker Compose v2** (`docker compose`) *(version minimale supposée, non précisée dans le dépôt)*
- `bash` et [`shellcheck`](https://www.shellcheck.net/) pour lancer `scripts/check.sh`
- Le port 8080 libre sur la machine

## Installation

```bash
git clone https://github.com/ClementLacoste7/TP_clement_lacoste_swann.git
cd TP_clement_lacoste_swann
docker compose up -d
```

Aucun fichier `.env` n'est nécessaire pour le moment. S'il en faut un plus tard, il ne doit jamais être commité (il est déjà dans le `.gitignore`).

## Utilisation

| Action | Commande |
| --- | --- |
| Démarrer | `docker compose up -d` |
| Voir l'état et le healthcheck | `docker compose ps` |
| Consulter les journaux | `docker compose logs -f web` |
| Recharger après modification de `nginx/default.conf` | `docker compose restart web` |
| Arrêter | `docker compose down` |

L'intranet est ensuite accessible sur <http://localhost:8080>.

Pour modifier le contenu, éditez les fichiers de `site/` : ils sont montés directement dans le conteneur, aucun redémarrage n'est nécessaire.

## Vérifications

Avant chaque commit, lancez :

```bash
./scripts/check.sh
```

Le script vérifie :

1. la syntaxe du `docker-compose.yml` (`docker compose config --quiet`) ;
2. la configuration Nginx (`nginx -t` dans un conteneur jetable) ;
3. les scripts shell avec `shellcheck`.

Il s'arrête à la première erreur et affiche `OK` si tout passe.

## Contribution

- La branche `main` est protégée : toute modification passe par une **pull request**.
- Nommage des branches : `feature/<sujet>`, `fix/<n° issue>-<sujet>`, `docs/<n° issue>-<sujet>`.
- Messages de commit au format [Conventional Commits](https://www.conventionalcommits.org/fr/) : `feat(deploy): …`, `fix(nginx): …`, `docs(readme): …`.
- Commentaires de review au format [Conventional Comments](https://conventionalcomments.org/) : `issue (blocking): …`, `suggestion (non-blocking): …`, `question: …`.
- Les issues utilisent les modèles « Bug / incident » et « Évolution / documentation » ; la PR référence son issue avec `Closes #<n°>`.
- Les PR sont mergées en **Squash and merge**.
- Les fichiers sont relus par les propriétaires définis dans `.github/CODEOWNERS`.
- Aucun secret (mot de passe, token, clé) ne doit être commité.
