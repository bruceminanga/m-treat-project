# ==============================================================================
# 1. The House (VPC)
# ==============================================================================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-custom-vpc"
  }
}

# ==============================================================================
# 2. The Front Door or main gate (Internet Gateway)
# ==============================================================================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# ==============================================================================
# 3. The Living Room (Public Subnet)
# ==============================================================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

# ==============================================================================
# 4. Public Direction Sign & Wiring like a road sign(Route Table + Association)
# ==============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# (The wiring stays right here with its parent table)
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# 5. The Back Bedroom (Private Subnet - For DBs & Sensitive Workloads)
# ==============================================================================
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false   # 👈 No public IPs allowed!

  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

# ==============================================================================
# 6. The House Wi-Fi Router (NAT Gateway + Private Route Table)
# ==============================================================================
# A dedicated public IP so the router can talk to the public internet
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# The NAT Gateway acts like your home Wi-Fi router:
# It sits in the public room and lets private devices fetch web data,
# while keeping them completely hidden and unreachable from the outside.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.environment}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}

# The private road sign: send outbound internet requests (0.0.0.0/0)
# to the NAT Gateway router, NEVER directly to the main front door (IGW).
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

# Connect the private back bedroom (subnet) to this router road sign
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}