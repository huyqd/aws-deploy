data "tls_certificate" "this" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fp-default"
  pod_execution_role_arn = aws_iam_role.fargate-pod-execution-role.arn
  subnet_ids             = aws_subnet.private.*.id

  selector {
    namespace = "default"
  }

#  selector {
#    namespace = "2048-game"
#  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "deployment-2048"
    namespace = "default"
    labels    = {
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

  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-2048"
    namespace = "default"
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

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}