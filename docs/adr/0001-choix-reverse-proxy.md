# ADR 0001 – Choix du reverse proxy : Traefik

- **Statut** : accepté
- **Date** : 2026-10-06
- **Décideurs** : équipe infra

## Contexte

L'équipe héberge une quinzaine de services en conteneurs Docker répartis sur deux serveurs. Un reverse proxy doit centraliser l'accès à ces services (routage par nom de domaine, terminaison TLS).

Contraintes :

- **De nouveaux services sont ajoutés chaque mois** : chaque ajout doit demander le moins de manipulations possible.
- **Le renouvellement des certificats TLS est fait à la main** et a déjà provoqué une coupure de service quand un certificat a expiré.
- **L'équipe connaît bien Nginx, mais pas Traefik.**

## Options envisagées

### Option 1 – Nginx

- Avantages :
  - maîtrisé par toute l'équipe, donc pas de formation et un dépannage rapide ;
  - très performant, stable, largement documenté ;
  - configuration explicite, facile à relire en PR.
- Inconvénients :
  - chaque nouveau service demande d'écrire un bloc `server`, de recharger Nginx et de gérer son certificat : une quinzaine de fichiers à maintenir à la main ;
  - pas de gestion native des certificats : il faut ajouter Certbot, un cron de renouvellement et un rechargement de Nginx, c'est-à-dire précisément ce qui a déjà échoué ;
  - aucune découverte automatique des conteneurs Docker.

### Option 2 – Traefik

- Avantages :
  - **découverte automatique** des conteneurs via le provider Docker : un service est publié en ajoutant quelques labels dans son `docker-compose.yml`, sans toucher au proxy ;
  - **certificats Let's Encrypt obtenus et renouvelés automatiquement** (ACME), ce qui supprime la cause de la coupure passée ;
  - tableau de bord et métriques intégrés pour voir les routes actives.
- Inconvénients :
  - l'équipe ne le connaît pas : temps de prise en main et risque d'erreurs au début ;
  - la configuration est répartie dans les labels de chaque service, moins centralisée qu'un fichier Nginx ;
  - Traefik a besoin d'accéder au socket Docker, ce qui doit être sécurisé.

## Décision

Nous retenons **Traefik**.

Les deux problèmes qui coûtent le plus à l'équipe sont l'ajout régulier de services et le renouvellement manuel des certificats, qui a déjà coupé la production. Traefik les règle tous les deux nativement, alors qu'avec Nginx il faudrait les compenser par de l'outillage maison (Certbot, cron, templates).

Le manque de connaissance de Traefik est un risque réel mais temporaire. Il est traité par les mesures ci-dessous, alors que le renouvellement manuel resterait un risque permanent.

## Conséquences

- **Plus simple** :
  - publier un nouveau service = ajouter des labels Traefik dans son `docker-compose.yml` ;
  - plus aucune intervention manuelle pour les certificats TLS ;
  - une configuration homogène sur les deux serveurs.
- **Plus difficile** :
  - montée en compétence nécessaire sur Traefik (routers, services, middlewares) ;
  - le dépannage s'appuiera sur le dashboard et les journaux de Traefik plutôt que sur des fichiers Nginx bien connus.
- **Actions à prévoir** :
  - former l'équipe (atelier interne + documentation officielle) avant la bascule ;
  - migrer d'abord un service peu critique (l'intranet), puis les autres progressivement ;
  - écrire un exemple de labels type dans le README pour les nouveaux services ;
  - protéger l'accès au socket Docker (lecture seule, ou docker-socket-proxy) et le dashboard (authentification, accès interne uniquement) ;
  - surveiller la date d'expiration des certificats, au moins pendant les premiers mois.
