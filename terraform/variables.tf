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

variable "jenkins_instance_type" {
  description = "EC2 instance type for the Jenkins server."
  type        = string
  default     = "t3.medium"
}

variable "dashboard_instance_type" {
  description = "EC2 instance type for the Traffic Dashboard server."
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach to the instances for SSH access. Leave as an empty string to launch instances without a key pair (access via SSM only)."
  type        = string
  default     = ""
}

variable "root_volume_size_gb" {
  description = "Size (in GB) of the root EBS volume for each EC2 instance."
  type        = number
  default     = 20
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
