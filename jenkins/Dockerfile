# ============================================================
#  Dockerfile — Custom Jenkins Image
#  Adds Docker CLI (Docker-outside-of-Docker), Node.js and
#  Python so pipeline stages can build/push images and run
#  the project's install/test/quality checks natively.
# ============================================================

FROM jenkins/jenkins:lts-jdk17

USER root

# Docker CLI + Compose plugin (talks to the HOST daemon via the
# socket mounted at /var/run/docker.sock — no nested dockerd needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release python3 python3-pip && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Pre-install the plugins the Jenkinsfile needs so the job works
# right after the container starts (no manual plugin install step).
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins
