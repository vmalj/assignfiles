# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.trimble_main.id
}

# Public subnet1
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.trimble_main.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "us-west-2a"
  depends_on = aws_internet_gateway.igw
  tags { 
    Name = "public" 
  }
}

# Public subnet2
resource "aws_subnet" "public2" {
  vpc_id            = "10.0.1.0/26"
  cidr_block        = var.public_subnet_cidr
  availability_zone = "us-west-2b"
  depends_on = aws_internet_gateway.igw
  tags { 
    Name = "public" 
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Route table associate public1
resource "aws_route_table_association" "publica" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# Route table associate public2
resource "aws_route_table_association" "publicb" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}