variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_name" {
  default = "MyVPC"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t2.micro"
}


