  ######## VPC CREATION #########

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

 ######## EKS CREATION #########

#creating IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach IAM role to master node policy

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


#Creating EKS cluster

resource "aws_eks_cluster" "my_eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.mysubnet.id] # Use your public/private subnets
  }

  tags = {
    Name = "My-EKS-Cluster"
  }
}

#Create IAM Role for Worker Nodes

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })


# Attach IAM role to worker node policy

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

##Create EKS Node Group (Worker Nodes)

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name  = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "my-node-group"
  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [aws_subnet.mysubnet.id]  # Associate nodes with subnets
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  tags = {
    Name = "EKS-Worker-Nodes"
  }
}




