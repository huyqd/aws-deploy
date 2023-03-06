resource "aws_eks_cluster" "main" {
  name     = local.project_name
  role_arn = aws_iam_role.eks-cluster-role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)
    public_access_cidrs     = ["0.0.0.0/0"]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  timeouts {
    delete = "30m"
  }

  depends_on = [
    aws_cloudwatch_log_group.aws-deploy,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "kube-system"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids      = aws_subnet.private.*.id

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 4
  }

  instance_types = ["t2.micro"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_cloudwatch_log_group" "aws-deploy" {
  name = "${local.project_name}-${local.environment}"
}

resource "aws_cloudwatch_log_stream" "aws-deploy" {
  log_group_name = "${local.project_name}-${local.environment}"
  name           = "${local.project_name}-${local.environment}"
  depends_on     = [aws_cloudwatch_log_group.aws-deploy]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}


resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.fargate-pod-execution-role.arn

  # These subnets must have the following resource tag:
  # kubernetes.io/cluster/<CLUSTER_NAME>.
  subnet_ids = aws_subnet.private.*.id

  selector {
    namespace = "kube-system"
  }
}
