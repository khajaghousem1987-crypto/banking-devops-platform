resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true

  tags = {

    Name = "${var.project_name}-vpc"

  }

}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = false
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = false
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az1
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az2
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public1" {

  subnet_id = aws_subnet.public1.id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public2" {

  subnet_id = aws_subnet.public2.id

  route_table_id = aws_route_table.public.id

}
resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {

    Name = "${var.project_name}-nat-eip"

  }

}

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public1.id

  depends_on = [

    aws_internet_gateway.igw

  ]

  tags = {

    Name = "${var.project_name}-nat"

  }

}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id

  }

}

resource "aws_route_table_association" "private1" {

  subnet_id = aws_subnet.private1.id

  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "private2" {

  subnet_id = aws_subnet.private2.id

  route_table_id = aws_route_table.private.id

}

 