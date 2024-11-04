resource "aws_iam_role" "eks"{
  name = "$[local.env}-${local.eks_name}-eks-cluster"

  assume_role_policy = <<POLICY {
    "Version" = "2012-10-17",
    "statement" = [
  {
    "Effect" : "Allow",
    "Action" : "sts:AssumeRole",
    "Principal" : {
       "service" : "eks.amazonaws.com
    }
  }
]
POLICY
}

resource "aws_iam_role_policy_attachment" "eks"{
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks"{
  name = "${local.env}-${local.eks_name}"
  role_arn = aws_iam_role_eks.arn
  version = local.eks_version

  vpc_config {
      Enable_private_access = false
      Enable_public_access = true

      subnets = [
        aws_subnets.private_subnet1.zonel.id,
        aws_subnets.private_subnet2.zone2.id
      ]
   }
  
    access_config {
        authentication_mode = "API"
        bootstrap_cluster_creator_admin_permissions = true
    }

depends_on = [aws_iam_role_policy_attachment.eks]
}
   
