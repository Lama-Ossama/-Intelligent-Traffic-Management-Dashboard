output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instances."
  value       = aws_security_group.app.id
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins EC2 instance."
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance."
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL to reach the Jenkins web UI."
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "dashboard_instance_id" {
  description = "Instance ID of the Traffic Dashboard EC2 instance."
  value       = aws_instance.dashboard.id
}

output "dashboard_public_ip" {
  description = "Public IP address of the Traffic Dashboard EC2 instance."
  value       = aws_instance.dashboard.public_ip
}

output "dashboard_url" {
  description = "URL to reach the Traffic Dashboard app."
  value       = "http://${aws_instance.dashboard.public_ip}:3002"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for traffic data/artifacts, if created."
  value       = var.create_s3_bucket ? aws_s3_bucket.traffic_data[0].id : null
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the EC2 instances."
  value       = aws_iam_role.ec2_role.name
}
