#creating VPC
resource "aws_vpc" "myvpc" {
  name = var.vpc_name
  cidr_block = var.cidr_block
}

resource "aws_subnet" "mysubnet" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.az.names
  cidr_block = ["10.0.0.0/24"]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" igw" {
 vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route{
    cidr_block = ["0.0.0.0/0"]
    gateway_id = aws_gateway.igw.id
   }
}

resource "aws_route_table_association"



# Create an EC2 Instance
resource "aws_instance" "my_ec2" {
  ami                    = "ami-04681163a08179f28"  
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "My-Terraform-EC2"
  }
}
