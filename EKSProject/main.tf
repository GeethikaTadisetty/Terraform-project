# Define AWS Availability Zones
data "aws_availability_zones" "az" {}

# Creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

# Creating Public Subnet
resource "aws_subnet" "mysubnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.az.names[0] # Corrected
  cidr_block        = "10.0.0.0/24"  # Should be a string, not a list
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "igw" { # Fixed resource name syntax
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Internet-Gateway"
  }
}

# Creating Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Should be a string, not a list
    gateway_id = aws_internet_gateway.igw.id  # Fixed reference
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}

# Creating Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-Security-Group"
  }
}

