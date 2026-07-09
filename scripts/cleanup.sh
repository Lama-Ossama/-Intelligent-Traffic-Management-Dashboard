#!/usr/bin/env bash
# ============================================================
# cleanup.sh — Tear down the local stack and reclaim disk space
#
# Stops and removes containers/networks/volumes for this
# project, then prunes dangling images left behind by repeated
# `docker compose up --build` runs.
#
# Usage:
#   scripts/cleanup.sh          # stop stack + prune dangling images
#   scripts/cleanup.sh --deep   # also prune the Docker build cache
# ============================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Stopping and removing containers, networks and volumes..."
docker compose down -v --remove-orphans

echo "Pruning dangling images..."
docker image prune -f

if [[ "${1:-}" == "--deep" ]]; then
  echo "Deep clean: pruning build cache..."
  docker builder prune -f
fi

echo "Cleanup complete."
