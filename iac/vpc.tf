####### VPC #######
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_1
  availability_zone = var.az1

  tags = {
    Name = "${var.vpc_name}-public-subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_2
  availability_zone = var.az2

  tags = {
    Name = "${var.vpc_name}-public-subnet_2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_3
  availability_zone = var.az3

  tags = {
    Name = "${var.vpc_name}-public-subnet_3"
  }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_1
  availability_zone = var.az1

  tags = {
    Name = "${var.vpc_name}-private-subnet_1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_2
  availability_zone = var.az2

  tags = {
    Name = "${var.vpc_name}-private-subnet_2"
  }
}
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_3
  availability_zone = var.az3

  tags = {
    Name = "${var.vpc_name}-private-subnet_3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "app_vpc_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Public network route-table
resource "aws_route_table" "app_vpc_rt_pub" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-rt-pub"
  }
}
resource "aws_route" "app_vpc_rt_pub_route01" {
  route_table_id         = aws_route_table.app_vpc_rt_pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_vpc_igw.id
  depends_on             = [aws_route_table.app_vpc_rt_pub]
}
resource "aws_route_table_association" "app_vpc_rt_pub_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.app_vpc_rt_pub.id
}
resource "aws_route_table_association" "app_vpc_rt_pub_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.app_vpc_rt_pub.id
}
resource "aws_route_table_association" "app_vpc_rt_pub_association_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.app_vpc_rt_pub.id
}

# Private network route-table
resource "aws_route_table" "app_vpc_rt_pvt" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-rt-pvt"
  }
}

resource "aws_route_table_association" "app_vpc_rt_pvt_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.app_vpc_rt_pvt.id
}
resource "aws_route_table_association" "app_vpc_rt_pvt_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.app_vpc_rt_pvt.id
}
resource "aws_route_table_association" "app_vpc_rt_pvt_association_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.app_vpc_rt_pvt.id
}
