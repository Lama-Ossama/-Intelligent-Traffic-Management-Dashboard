#!/usr/bin/env bash
# ============================================================
# health-check.sh — Verify the Traffic Dashboard is responding
#
# Usage:
#   scripts/health-check.sh                    # curl from the host (local dev)
#   scripts/health-check.sh <container-name>   # wget from inside a container (CI mode,
#                                               # used when docker-compose.ci.yml has
#                                               # dropped the published host port)
# ============================================================
set -euo pipefail

HOST="${DASHBOARD_HOST:-localhost}"
PORT="${DASHBOARD_PORT:-3002}"
CONTAINER="${1:-}"

check() {
  local path="$1"
  local label="$2"

  if [[ -n "$CONTAINER" ]]; then
    docker exec "$CONTAINER" wget -q -O- "http://localhost:${PORT}${path}" > /dev/null
  else
    curl -fsS "http://${HOST}:${PORT}${path}" > /dev/null
  fi

  echo "OK  ${label} (${path})"
}

echo "Checking traffic-dashboard..."
check "/health"      "health check"
check "/"            "dashboard page"
check "/api/traffic" "traffic API"
check "/metrics"     "prometheus metrics"
echo "All checks passed."
