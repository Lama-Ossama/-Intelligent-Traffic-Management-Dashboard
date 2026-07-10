#!/usr/bin/env bash
# ============================================================
# ci-test.sh — Shared integration-test logic for CI
#
# Used identically by the Jenkinsfile and the GitHub Actions
# workflow so both pipelines run the exact same checks instead
# of maintaining two copies of the same shell inline.
#
# Respects COMPOSE_FILES / COMPOSE_PROJECT_NAME from the
# environment (both pipelines set these to isolate concurrent
# runs); falls back to sane defaults for a local run.
# ============================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

export COMPOSE_FILES="${COMPOSE_FILES:--f docker-compose.yml -f docker-compose.ci.yml}"

# docker-compose.yml interpolates every service's env vars up front, even
# when only building/starting a subset -- so GRAFANA_ADMIN_PASSWORD's
# required-value check trips even though CI never touches the grafana
# service. It's not used for anything here, so a throwaway default is fine.
export GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-ci-placeholder}"

cleanup() {
  echo "Tearing down CI stack..."
  docker compose $COMPOSE_FILES down -v --remove-orphans || true
}
trap cleanup EXIT

echo "Pre-clean: removing any stale stack from a previous run..."
docker compose $COMPOSE_FILES down -v --remove-orphans || true

echo "Building images..."
docker compose $COMPOSE_FILES build traffic-collector traffic-dashboard

echo "Starting containers..."
docker compose $COMPOSE_FILES up -d traffic-collector traffic-dashboard
sleep 10

CID=$(docker compose $COMPOSE_FILES ps -q traffic-dashboard)
"$PROJECT_ROOT/scripts/health-check.sh" "$CID"

echo "Integration checks passed."
