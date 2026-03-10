# ──────────────────────────────────────────
# S3 BUCKET FOR FLOW LOG ARCHIVE
# Long term storage and Athena analysis
# ──────────────────────────────────────────
resource "aws_s3_bucket" "flow_logs" {
  bucket        = "${var.project_name}-flow-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ──────────────────────────────────────────
# CLOUDWATCH LOG GROUP
# Real time flow log analysis and alerting
# ──────────────────────────────────────────
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/flow-logs/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# ──────────────────────────────────────────
# IAM ROLE FOR FLOW LOGS
# Grants VPC Flow Logs permission to write
# to CloudWatch on your behalf
# ──────────────────────────────────────────
resource "aws_iam_role" "flow_logs" {
  name = "${var.project_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-flow-logs-role"
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ──────────────────────────────────────────
# VPC FLOW LOG → CLOUDWATCH
# Real time traffic metadata capture
# ──────────────────────────────────────────
resource "aws_flow_log" "cloudwatch" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name = "${var.project_name}-flow-log-cloudwatch"
  }
}

# ──────────────────────────────────────────
# VPC FLOW LOG → S3
# Long term archive for forensics and Athena
# ──────────────────────────────────────────
resource "aws_flow_log" "s3" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flow_logs.arn

  tags = {
    Name = "${var.project_name}-flow-log-s3"
  }
}

# ──────────────────────────────────────────
# DATA SOURCE
# Fetches your AWS account ID dynamically
# Used to create a globally unique S3 bucket name
# ──────────────────────────────────────────
data "aws_caller_identity" "current" {}