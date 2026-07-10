#########################################
# Data sources
#########################################

# Latest Amazon Linux 2023 AMI, kept up to date automatically.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

#########################################
# Networking: VPC, subnets, IGW, routes
#########################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  # Note: since Feb 2024 AWS bills ~$0.005/hr per public IPv4 address
  # while it's attached to a running instance -- not covered by Free
  # Tier. Needed here so the dashboard is reachable over HTTP without
  # a NAT Gateway or Load Balancer (both far more expensive). The
  # charge stops as soon as the instance is stopped/destroyed.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#########################################
# Security group
#########################################

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, Jenkins, Traffic Dashboard, and Grafana traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Only opened when the Jenkins instance actually exists -- no point
  # exposing a port nothing is listening on.
  dynamic "ingress" {
    for_each = var.create_jenkins ? [1] : []
    content {
      description = "Jenkins web UI"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "Traffic Dashboard app"
    from_port   = 3002
    to_port     = 3002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

#########################################
# IAM role / instance profile for EC2
#########################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Allows Session Manager access to the instances without opening SSH to the world.
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "s3_access" {
  count = var.create_s3_bucket ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.traffic_data[0].arn,
      "${aws_s3_bucket.traffic_data[0].arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  count = var.create_s3_bucket ? 1 : 0

  name   = "${var.project_name}-s3-access"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.s3_access[0].json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

#########################################
# S3 bucket for traffic data / backups
#########################################

resource "aws_s3_bucket" "traffic_data" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"

  # Lets `terraform destroy` remove the bucket even if backup-data.sh
  # has left objects/versions in it -- see s3_force_destroy.
  force_destroy = var.s3_force_destroy

  tags = {
    Name = "${var.project_name}-data"
  }
}

resource "aws_s3_bucket_versioning" "traffic_data" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.traffic_data[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bounds storage growth from scripts/backup-data.sh, which writes a
# new timestamped object on every run and never overwrites/deletes
# old ones -- without this, storage (and any post-Free-Tier cost)
# grows forever.
resource "aws_s3_bucket_lifecycle_configuration" "traffic_data" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.traffic_data[0].id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    filter {
      prefix = "backups/"
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.traffic_data]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "traffic_data" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.traffic_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "traffic_data" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.traffic_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################
# EC2 instances
#########################################

locals {
  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  # Installs Docker + the Compose plugin on Amazon Linux 2023.
  # Script lives at scripts/ec2-bootstrap.sh so it can be run/tested
  # standalone instead of only as an opaque inline heredoc.
  docker_bootstrap = file("${path.module}/../scripts/ec2-bootstrap.sh")
}

resource "aws_instance" "jenkins" {
  count = var.create_jenkins ? 1 : 0

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.jenkins_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = local.key_name
  user_data              = local.docker_bootstrap

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-jenkins"
    Role = "jenkins"
  }
}

resource "aws_instance" "dashboard" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.dashboard_instance_type
  subnet_id              = aws_subnet.public[length(aws_subnet.public) > 1 ? 1 : 0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = local.key_name
  user_data              = local.docker_bootstrap

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-dashboard"
    Role = "traffic-dashboard"
  }
}
