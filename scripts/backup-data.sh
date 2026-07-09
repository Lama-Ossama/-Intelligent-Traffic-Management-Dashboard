#!/usr/bin/env bash
# ============================================================
# backup-data.sh — Back up Traffic.csv to the project's S3 bucket
#
# The bucket is provisioned by terraform/main.tf when
# create_s3_bucket = true. Requires the AWS CLI to be configured
# with credentials that can write to the bucket.
#
# Usage:
#   scripts/backup-data.sh <bucket-name>
#   scripts/backup-data.sh                 # reads the bucket name
#                                           # from `terraform output`
# ============================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUCKET="${1:-}"
if [[ -z "$BUCKET" ]]; then
  BUCKET="$(cd "$PROJECT_ROOT/terraform" && terraform output -raw s3_bucket_name 2>/dev/null || true)"
fi

if [[ -z "$BUCKET" || "$BUCKET" == "null" ]]; then
  echo "No S3 bucket name given and none found via 'terraform output'." >&2
  echo "Usage: scripts/backup-data.sh <bucket-name>" >&2
  exit 1
fi

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
SOURCES=(
  "$PROJECT_ROOT/traffic-collector/Traffic.csv"
  "$PROJECT_ROOT/traffic-dashboard/data/Traffic.csv"
)

for src in "${SOURCES[@]}"; do
  if [[ ! -f "$src" ]]; then
    echo "Skipping missing file: $src" >&2
    continue
  fi
  name="$(basename "$(dirname "$src")")-Traffic.csv"
  dest="s3://${BUCKET}/backups/${TIMESTAMP}/${name}"
  echo "Uploading ${src} -> ${dest}"
  aws s3 cp "$src" "$dest"
done

echo "Backup complete: s3://${BUCKET}/backups/${TIMESTAMP}/"
