#!/usr/bin/env bash
# ============================================================
# k8s-create-secret.sh — Create the Docker Hub image-pull secret
#
# k8s/02-secrets-configmap.yaml used to hardcode this secret's base64
# credential directly in git — removed, since a committed Secret manifest
# ships the credential with the repo forever, even after rotation.
#
# Run this once per cluster/namespace, using a Docker Hub access token
# (Account Settings -> Security -> New Access Token), NOT your password,
# before `kubectl apply -k k8s/`. Safe to re-run (idempotent).
#
# Usage:
#   DOCKERHUB_USERNAME=myuser DOCKERHUB_TOKEN=dckr_pat_xxx scripts/k8s-create-secret.sh
# ============================================================
set -euo pipefail

: "${DOCKERHUB_USERNAME:?Set DOCKERHUB_USERNAME}"
: "${DOCKERHUB_TOKEN:?Set DOCKERHUB_TOKEN}"
NAMESPACE="${NAMESPACE:-traffic-system}"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret docker-registry docker-hub-secret \
  --docker-server=docker.io \
  --docker-username="$DOCKERHUB_USERNAME" \
  --docker-password="$DOCKERHUB_TOKEN" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "docker-hub-secret created/updated in namespace $NAMESPACE"
