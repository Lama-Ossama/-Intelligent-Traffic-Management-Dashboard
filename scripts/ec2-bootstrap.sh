#!/bin/bash
# ============================================================
# ec2-bootstrap.sh — EC2 user-data bootstrap (Amazon Linux 2023)
#
# Installs Docker + the Compose plugin and enables the docker
# group for ec2-user. Referenced by terraform/main.tf as the
# user_data script for both the Jenkins and dashboard instances.
# ============================================================
set -e

dnf update -y
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

DOCKER_CONFIG_DIR=/usr/local/lib/docker/cli-plugins
mkdir -p "$DOCKER_CONFIG_DIR"
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o "$DOCKER_CONFIG_DIR/docker-compose"
chmod +x "$DOCKER_CONFIG_DIR/docker-compose"
