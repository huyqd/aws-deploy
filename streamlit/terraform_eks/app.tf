resource "aws_eks_fargate_profile" "fp-default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fp-default"
  pod_execution_role_arn = aws_iam_role.fargate-pod-execution-role.arn

  # These subnets must have the following resource tag:
  # kubernetes.io/cluster/<CLUSTER_NAME>.
  subnet_ids = aws_subnet.private.*.id

  selector {
    namespace = "fp-default"
  }
}

resource "kubernetes_namespace" "fp-default" {
  metadata {
    name = "fp-default"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "deployment-2048"
    namespace = "fp-default"
    labels = {
      app = "2048"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "2048"
      }
    }

    template {
      metadata {
        labels = {
          app = "2048"
        }
      }

      spec {
        container {
          image = "alexwhen/docker-2048"
          name  = "2048"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [aws_eks_fargate_profile.fp-default]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-2048"
    namespace = "fp-default"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.app]
}