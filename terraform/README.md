# Terraform — AWS Free Tier Notes

This module provisions the AWS infrastructure for the project's non-Kubernetes
deployment path (see the root README for the Kubernetes path). Defaults are
tuned to stay inside the [AWS Free Tier](https://aws.amazon.com/free/) for a
demo/project environment — read this before running `terraform apply`.

## What gets created by default

With no `terraform.tfvars` overrides (`create_jenkins = false`):

| Resource | Free Tier? |
|---|---|
| VPC, subnets, Internet Gateway, route tables, security group | Always free |
| IAM role, instance profile, policies | Always free |
| 1x EC2 instance (`traffic-dashboard`, `t3.micro`) | Free — within the 750 hrs/month pool |
| 1x EBS root volume (10 GB gp3) | Free — within the 30 GB/account pool |
| 1x S3 bucket (versioned, encrypted, lifecycle-managed) | Free — within the 5 GB/account pool (new accounts, first 12 months) |
| Public IPv4 on the dashboard instance | **Not Free Tier** — see below |

## The one charge you can't avoid: public IPv4

Since February 2024, AWS bills **~$0.005/hr (~$3.65/month)** for any public
IPv4 address attached to a running instance — regardless of whether it's an
Elastic IP or an auto-assigned one. This is a separate, permanent charge, not
part of the 12-month Free Tier.

This repo doesn't provision an `aws_eip` (which avoids the classic "forgot to
release an unattached Elastic IP" trap), but the dashboard instance still
needs a public IP to be reachable over HTTP without standing up a NAT Gateway
or Load Balancer — both of which cost far more. The charge stops the moment
you `terraform destroy` or stop the instance.

## Guardrails baked into the defaults

- **`create_jenkins` defaults to `false`.** Jenkins already runs locally via
  `docker-compose.yml` / the `Jenkinsfile`; most demos don't need a second
  always-on EC2 instance. AWS's 750 free EC2 hours/month is a **combined**
  pool across every running t2.micro/t3.micro instance, not 750 hours *each*
  — running both instances 24/7 for a full month (2 × 730 hrs) exceeds it.
- **Instance types are restricted by `validation` blocks** to
  `t2.micro`/`t3.micro` only. A typo'd or copy-pasted `t3.medium` in your
  `terraform.tfvars` fails at `terraform plan`, not on your bill. Edit the
  `contains([...])` list in `variables.tf` yourself if you deliberately want
  something bigger.
- **`root_volume_size_gb` defaults to 10** (validated `<= 30`). Free Tier
  covers 30 GB of EBS storage total across the whole account, so even
  dashboard + Jenkins together (2 × 10 GB) stay under the cap.
- **S3 lifecycle rule** expires objects under `backups/` (written by
  `scripts/backup-data.sh`) and old object versions after 30 days, so
  repeated backups can't grow storage — and cost — unbounded.

## Optional / billable if you turn them on

| Variable | Default | Turns on |
|---|---|---|
| `create_jenkins` | `false` | A second EC2 instance + EBS volume + public IPv4 charge |
| `create_s3_bucket` | `true` | An S3 bucket (Free Tier: 5 GB, first 12 months only) |

## Always destroy when you're done

```bash
terraform destroy
```

`s3_force_destroy = true` by default so the S3 bucket is removed cleanly even
if `scripts/backup-data.sh` has written objects into it. If you ever store
something in that bucket you can't afford to lose to a stray `destroy`, set
`s3_force_destroy = false` first.

## Not present in this module

No NAT Gateway, Load Balancer, RDS, EKS, ElastiCache, or Elastic IP resources
are defined here — nothing to audit or disable on that front.

## Verifying you're within Free Tier

Free Tier terms change over time and depend on your account's age/region —
double-check the current limits on the
[AWS Free Tier page](https://aws.amazon.com/free/) and your
[AWS Billing dashboard](https://console.aws.amazon.com/billing/) rather than
relying solely on this document.
