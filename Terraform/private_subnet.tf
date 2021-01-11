# Private Subnet1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.trimble_main.id
  cidr_block        = "10.0.2.0/26"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false
  depends_on = aws_nat_gateway.natgw
  tags { 
    Name = "private" 
  }
}


# Private Subnet2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.trimble_main.id
  cidr_block        = "10.0.3.0/26"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = false
  depends_on = aws_nat_gateway.natgw
  tags { 
    Name = "private" 
  }
}


# Private Routing Table 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.trimble_main.id
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_nat_gateway.natgw.id
  }
}

# Private Routing Table Association Private1
resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

# Private Routing Table Association Private2
resource "aws_route_table_association" "private2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# Eip for NAT GW
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = aws_internet_gateway.igw
}

# Nat Gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  depends_on = aws_internet_gateway.igw
}  