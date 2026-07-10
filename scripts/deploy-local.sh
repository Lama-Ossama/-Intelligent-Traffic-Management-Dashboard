#!/usr/bin/env bash
# ============================================================
# deploy-local.sh — Build and start the local dev stack
#
# Starts traffic-collector, traffic-dashboard and prometheus,
# waits for the dashboard to become healthy, then prints the
# URLs to open.
#
# Usage:
#   scripts/deploy-local.sh                 # default services
#   scripts/deploy-local.sh --with-jenkins  # also start local Jenkins
# ============================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

SERVICES=(traffic-collector traffic-dashboard prometheus)
[[ "${1:-}" == "--with-jenkins" ]] && SERVICES+=(jenkins)

echo "Building and starting: ${SERVICES[*]}"
docker compose up --build -d "${SERVICES[@]}"

echo "Waiting for traffic-dashboard to become healthy..."
for i in $(seq 1 30); do
  if "$PROJECT_ROOT/scripts/health-check.sh" > /dev/null 2>&1; then
    echo "Dashboard is up."
    break
  fi
  if [[ "$i" -eq 30 ]]; then
    echo "Dashboard did not become healthy in time." >&2
    docker compose logs traffic-dashboard
    exit 1
  fi
  sleep 2
done

cat <<EOF

Traffic Dashboard : http://localhost:3002
Prometheus        : http://localhost:9090
EOF
if [[ " ${SERVICES[*]} " == *" jenkins "* ]]; then
  echo "Jenkins            : http://localhost:8080"
fi
