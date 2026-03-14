# ──────────────────────────────────────────
# PUBLIC ROUTE TABLE
# Routes internet traffic through IGW
# ──────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

# ──────────────────────────────────────────
# Associate both public subnets with the public route table
# ──────────────────────────────────────────
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ──────────────────────────────────────────
# PRIVATE ROUTE TABLE
# Routes outbound traffic through NAT Gateway
# ──────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-private"
  }
}

# ──────────────────────────────────────────
# Associate both private subnets with the private route table
# ──────────────────────────────────────────
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# ──────────────────────────────────────────
# DATA ROUTE TABLE
# No default route = no internet access at all
# ──────────────────────────────────────────
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  # Intentionally NO 0.0.0.0/0 route
  # Data subnets can only talk within the VPC

  tags = {
    Name = "${var.project_name}-rt-data"
  }
}

# ──────────────────────────────────────────
# Associate both data subnets with the data route table
# ──────────────────────────────────────────
resource "aws_route_table_association" "data_a" {
  subnet_id      = aws_subnet.data_a.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_b" {
  subnet_id      = aws_subnet.data_b.id
  route_table_id = aws_route_table.data.id
}