#!/usr/bin/env bash
# Vérifications avant commit : syntaxe compose, config nginx, scripts shell
set -euo pipefail

echo "==> docker compose config"
docker compose config --quiet

echo "==> nginx -t"
docker run --rm \
  -v "$PWD/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  nginx:1.27-alpine nginx -t

echo "==> shellcheck"
shellcheck scripts/*.sh

echo "OK"
