# Create VPC in us-east-1 region
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc"
  }

}

# Create public subnet
resource "aws_subnet" "vpc_public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.subnets_count)
  availability_zone       = element(var.availability_zone, count.index)
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${element(var.availability_zone, count.index)}"
  }

}

# Create private subnet
resource "aws_subnet" "vpc_private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.subnets_count)
  availability_zone = element(var.availability_zone, count.index)
  cidr_block        = "10.0.${count.index + 2}.0/24"

  tags = {
    Name = "private-subnet-${element(var.availability_zone, count.index)}"
  }

}

# Create Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

# Create public route table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
  }

}

# Create public route table association
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.subnets_count)
  subnet_id      = element(aws_subnet.vpc_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Create elastic IP
resource "aws_eip" "elasticIP" {
  count = length(var.subnets_count)
  vpc   = true

}

# Create NAT gateway 
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.subnets_count)
  allocation_id = element(aws_eip.elasticIP.*.id, count.index)
  subnet_id     = element(aws_subnet.vpc_public_subnet.*.id, count.index)

  tags = {
    Name = "nat-gateway"
  }

}

# Create private route table 
resource "aws_route_table" "private_route_table" {
  count  = length(var.subnets_count)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Create private route table association
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.subnets_count)
  subnet_id      = element(aws_subnet.vpc_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)

}

