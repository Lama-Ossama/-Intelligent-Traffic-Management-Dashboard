# Jenkins CI/CD Setup Guide

This project now has **two independent CI/CD pipelines**:

- **GitHub Actions** — `.github/workflows/ci-cd.yml` (unchanged, still runs on every push/PR to GitHub)
- **Jenkins** — `Jenkinsfile` (self-hosted, runs in a container started via `docker-compose.yml`)

They don't depend on each other and can run side by side.

## What Was Added

| File | Purpose |
|---|---|
| `jenkins/Dockerfile` | Custom Jenkins image: `jenkins/jenkins:lts-jdk17` + Docker CLI + `docker-compose-plugin` + Node.js 20 + Python3/pip, with required plugins pre-installed |
| `jenkins/plugins.txt` | Plugin list baked into the image (`git`, `workflow-aggregator`, `credentials-binding`, `github-branch-source`, `pipeline-stage-view`) |
| `Jenkinsfile` | Declarative pipeline: checkout → install deps → test → code quality → build images → push to Docker Hub |
| `docker-compose.yml` (`jenkins` service) | Runs Jenkins locally, alongside the existing `traffic-collector`, `traffic-dashboard`, and `prometheus` services |

## How It Works (Docker-outside-of-Docker)

The Jenkins container does **not** run its own Docker daemon. Instead, `/var/run/docker.sock` from the host is mounted into it, so `docker build` / `docker push` / `docker compose` commands run *inside* the Jenkins container but are executed *by the host's* Docker daemon. This is why the image only needs the Docker **CLI**, not a full Docker-in-Docker setup, and why the service runs as `user: root` (required to access the socket).

## 1. Start Jenkins

```bash
docker compose up -d --build jenkins
```

Jenkins will be available at **http://localhost:8080**.

## 2. Unlock Jenkins

On first start, get the initial admin password:

```bash
docker exec traffic-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste it into the setup wizard, then choose **"Install suggested plugins"** (the plugins required by the `Jenkinsfile` are already pre-installed via `plugins.txt`, so this just fills in the rest — search, matrix-auth, etc.) and create your admin user.

## 3. Add Docker Hub Credentials

The pipeline expects a credential named exactly `dockerhub-credentials`:

1. **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**
2. Kind: **Username with password**
3. Username: your Docker Hub username
4. Password: a Docker Hub **access token** (Docker Hub → Account Settings → Security → New Access Token — do not use your account password)
5. ID: `dockerhub-credentials` (must match the `Jenkinsfile`)

## 4. Create the Pipeline Job

Use a **Multibranch Pipeline** (not a plain Pipeline job) — the `Jenkinsfile`'s `when { branch 'main' }` push gate (mirroring the GitHub Actions `if: github.ref == 'refs/heads/main'` condition) only evaluates correctly when `BRANCH_NAME` is set, which Multibranch Pipeline provides automatically.

1. **New Item → Multibranch Pipeline**
2. **Branch Sources → Add → Git** (or **GitHub** if using the `github-branch-source` plugin with a repo URL/credentials)
3. Repository URL: this repo's clone URL
4. **Build Configuration → Mode: by Jenkinsfile**, Script Path: `Jenkinsfile` (default)
5. Save — Jenkins scans branches and runs the pipeline automatically on new commits

## Pipeline Stages

| Stage | What it does |
|---|---|
| Checkout | `checkout scm` — pulls the branch that triggered the build |
| Install Dependencies | `npm ci` in `traffic-dashboard/`; `pip3 install pandas` for the collector |
| Run Tests | Builds and starts both app containers, then runs `docker exec <container> wget ...` against `/` and `/api/traffic` from inside the container's own network namespace — this avoids the common Docker-outside-of-Docker trap where `localhost` inside the Jenkins container doesn't reach a sibling container's published port |
| Code Quality | `python -m py_compile` on the collector, `node -c` on the dashboard — same checks as the GitHub Actions `code-quality` job |
| Build Docker Images | Tags both images `latest` and `<BUILD_NUMBER>` |
| Push to Docker Hub | Only on the `main` branch; logs in with the `dockerhub-credentials` credential and pushes both tags for both images |

## Stopping Jenkins

```bash
docker compose stop jenkins
```

Jenkins state (jobs, credentials, plugins) persists in the `jenkins_home` named volume, so it survives restarts. To fully reset it:

```bash
docker compose down
docker volume rm intelligent-traffic-management-dashboard_jenkins_home
```

(Adjust the volume name to whatever `docker volume ls` shows — Compose prefixes it with the project/folder name.)
