// Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "vpc"
  }
}

// Create 2 public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cird[count.index]
  map_public_ip_on_launch = "true" //Makes subnet public
  availability_zone       = var.availability_zone[count.index]
  count = length(var.public_cird)
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

// Create internet gateway to access to internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

// Configure route table
resource "aws_route_table" "public-crt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.cidr_route
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-crt"
  }
}

// Attach to subnet
resource "aws_route_table_association" "crta-public" {
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public-crt.id
  count = length(var.public_cird)
}

// Create nodes security group
resource "aws_security_group" "nodes_sg" {
  name        = "k8s"
  description = "allow all"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "nodes_sg"
  }
}
