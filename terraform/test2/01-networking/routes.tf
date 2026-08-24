# 1. Route Table (Sends internet-bound traffic to the IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# 2. Route Table Association (Wires the subnet to the route table)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.custom_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}