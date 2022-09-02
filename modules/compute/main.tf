resource "aws_ecr_repository_policy" "demo-repo-policy" {
  repository = aws_ecr_repository.demo-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "k8s-cluster" {
  name = "k8s-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.k8s-cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
#===========================================================================#
resource "aws_iam_role" "k8s-node" {
  name = "k8s-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.k8s-node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.k8s-node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.k8s-node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_cluster" "k8s-cluster" {
  name     = "k8s"
  role_arn = aws_iam_role.k8s-cluster.arn
  vpc_config {
    subnet_ids         = [data.aws_subnet.public_subnet[0].id, data.aws_subnet.public_subnet[1].id]
    security_group_ids = [data.aws_security_group.nodes_sg.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_node_group" "k8s-node" {
  node_group_name = "node-woker"
  cluster_name    = aws_eks_cluster.k8s-cluster.name
  node_role_arn   = aws_iam_role.k8s-node.arn
  subnet_ids      = data.aws_subnet.public_subnet[*].id
  instance_types  = var.instance_types
  capacity_type   = "ON_DEMAND"
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_ecr_repository" "demo-repository" {
  name                 = "demo-repo"
  image_tag_mutability = "IMMUTABLE"
}

