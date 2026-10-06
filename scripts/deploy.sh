#!/bin/bash
# deploiement de l'intranet sur le serveur

SERVER=192.168.10.20
REGISTRY_TOKEN=ghp_9Xk2Lq7RtV4mN8bW1cZ5yH3jP6sD0fA2eG

echo "deploiement en cours..."

ssh root@$SERVER "mkdir -p /opt/intranet"
scp -r ./* root@$SERVER:/opt/intranet/

ssh root@$SERVER "chmod -R 777 /opt/intranet"

ssh root@$SERVER "echo $REGISTRY_TOKEN | docker login ghcr.io -u deploy --password-stdin"
ssh root@$SERVER "cd /opt/intranet && docker compose down && docker compose pull && docker compose up -d"

ssh root@$SERVER "rm -rf /opt/intranet/backup/*"

echo "deploiement termine"
