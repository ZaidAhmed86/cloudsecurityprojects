# ──────────────────────────────────────────
# S3 GATEWAY ENDPOINT
# Free - allows private/data subnets to reach
# S3 without traffic leaving the AWS network
# ──────────────────────────────────────────
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id,
    aws_route_table.data.id
  ]

  tags = {
    Name = "${var.project_name}-endpoint-s3"
  }
}

# ──────────────────────────────────────────
# DYNAMODB GATEWAY ENDPOINT
# Free - same concept as S3 endpoint
# ──────────────────────────────────────────
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id,
    aws_route_table.data.id
  ]

  tags = {
    Name = "${var.project_name}-endpoint-dynamodb"
  }
}