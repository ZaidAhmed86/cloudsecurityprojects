# ──────────────────────────────────────────
# Elastic IP for NAT Gateway
# ──────────────────────────────────────────
# NAT Gateway needs a static public IP address
resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-a"
  }

  depends_on = [aws_internet_gateway.main]
}

# ──────────────────────────────────────────
# NAT Gateway — sits in the PUBLIC subnet
# Private subnets route outbound traffic through this
# NOTE: We use 1 NAT Gateway (in AZ-a) to minimize cost
# In production you would have one per AZ for high availability
# ──────────────────────────────────────────
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.project_name}-nat-a"
  }

  depends_on = [aws_internet_gateway.main]
}