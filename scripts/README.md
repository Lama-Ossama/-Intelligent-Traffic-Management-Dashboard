# Scripts

Bash scripts used for local dev, CI, and AWS provisioning. All are safe to
run from the repo root or via `scripts/<name>.sh` from anywhere inside the repo.

| Script | Purpose |
|---|---|
| `deploy-local.sh` | Build and start the local dev stack (collector, dashboard, Prometheus), wait for health, print URLs. |
| `health-check.sh` | Curl/wget the dashboard's `/health`, `/`, `/api/traffic`, `/metrics` endpoints. Used standalone or by other scripts. |
| `ci-test.sh` | Shared integration-test logic used by both the Jenkinsfile and `.github/workflows/ci-cd.yml`. |
| `cleanup.sh` | Tear down the local stack and prune dangling Docker images (`--deep` also prunes build cache). |
| `backup-data.sh` | Upload `Traffic.csv` to the S3 bucket provisioned by `terraform/`. |
| `ec2-bootstrap.sh` | EC2 user-data script (Docker + Compose plugin install), referenced by `terraform/main.tf`. |
| `k8s-create-secret.sh` | Create the `docker-hub-secret` image-pull secret directly in the cluster — run once before `kubectl apply -k k8s/`. Not stored in git. |

## Usage

```bash
./scripts/deploy-local.sh
./scripts/health-check.sh
./scripts/cleanup.sh --deep
./scripts/backup-data.sh                # bucket name from `terraform output`
./scripts/backup-data.sh my-bucket-name
DOCKERHUB_USERNAME=me DOCKERHUB_TOKEN=dckr_pat_xxx ./scripts/k8s-create-secret.sh
```
