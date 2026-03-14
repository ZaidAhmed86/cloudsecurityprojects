# ──────────────────────────────────────────
# VPC OUTPUTS
# ──────────────────────────────────────────
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# ──────────────────────────────────────────
# SUBNET OUTPUTS
# ──────────────────────────────────────────
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "data_subnet_ids" {
  description = "IDs of the data subnets"
  value       = [aws_subnet.data_a.id, aws_subnet.data_b.id]
}

# ──────────────────────────────────────────
# NAT GATEWAY OUTPUTS
# ──────────────────────────────────────────
output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat_a.public_ip
}

# ──────────────────────────────────────────
# SECURITY GROUP OUTPUTS
# ──────────────────────────────────────────
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the app server security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

# ──────────────────────────────────────────
# FLOW LOGS OUTPUTS
# ──────────────────────────────────────────
output "flow_logs_bucket" {
  description = "Name of the S3 bucket storing flow logs"
  value       = aws_s3_bucket.flow_logs.bucket
}

output "flow_logs_cloudwatch_group" {
  description = "Name of the CloudWatch log group for flow logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

# ──────────────────────────────────────────
# VPC ENDPOINT OUTPUTS
# ──────────────────────────────────────────
output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}
