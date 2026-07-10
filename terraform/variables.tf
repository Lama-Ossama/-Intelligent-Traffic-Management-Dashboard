variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used as a prefix/tag for all resources."
  type        = string
  default     = "intelligent-traffic-management"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per availability zone)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to spread the public subnets across. Must match the length of public_subnet_cidrs."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the EC2 instances. Restrict this to your own IP in production (e.g. \"1.2.3.4/32\")."
  type        = string
  default     = "0.0.0.0/0"
}

# ── Free Tier guardrails ───────────────────────────────────
# AWS Free Tier EC2 (first 12 months on a new account) covers 750
# instance-hours/month TOTAL across every running t2.micro/t3.micro
# instance combined -- not 750 hours per instance. The validation
# blocks below exist so `terraform apply` can't silently create a
# billable instance size from a typo'd or copy-pasted tfvars value;
# edit the `contains([...])` list yourself if you deliberately want
# something bigger.

variable "create_jenkins" {
  description = "Whether to create the Jenkins EC2 instance. Defaults to false: Jenkins already runs locally via docker-compose.yml / the Jenkinsfile, so most demos don't need a second always-on EC2 instance. Enabling this adds a second instance's worth of EC2 + EBS + public-IPv4 charges and pushes combined EC2 hours past the 750/month Free Tier pool if left running."
  type        = bool
  default     = false
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for the Jenkins server. Restricted to Free-Tier-eligible types."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.jenkins_instance_type)
    error_message = "jenkins_instance_type must be Free-Tier-eligible: t2.micro or t3.micro."
  }
}

variable "dashboard_instance_type" {
  description = "EC2 instance type for the Traffic Dashboard server. Restricted to Free-Tier-eligible types."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.dashboard_instance_type)
    error_message = "dashboard_instance_type must be Free-Tier-eligible: t2.micro or t3.micro."
  }
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach to the instances for SSH access. Leave as an empty string to launch instances without a key pair (access via SSM only)."
  type        = string
  default     = ""
}

variable "root_volume_size_gb" {
  description = "Size (in GB) of the root EBS volume for each EC2 instance. AWS Free Tier covers 30 GB of EBS storage TOTAL across every volume in the account combined, so the default is kept low enough that dashboard + jenkins together (2 x 10 GB) still fit under that cap."
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size_gb <= 30
    error_message = "root_volume_size_gb must be <= 30 -- that's the entire Free Tier EBS allowance for the account, shared across every volume you provision."
  }
}

variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket for storing traffic data/artifacts and application backups."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Globally-unique name for the S3 bucket. Leave empty to auto-generate a name using project_name, environment and account ID."
  type        = string
  default     = ""
}

variable "s3_force_destroy" {
  description = "Allow `terraform destroy` to delete the S3 bucket even if it still contains objects/versions. Defaults to true since this bucket only holds demo/backup data (see scripts/backup-data.sh) -- flip to false if you ever store something you can't afford to lose to a stray destroy."
  type        = bool
  default     = true
}
