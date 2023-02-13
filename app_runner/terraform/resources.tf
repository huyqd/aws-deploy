resource "aws_s3_bucket" "aws-deploy" {
  bucket = "${local.project_name}-${local.environment}"
}


resource "aws_ecr_repository" "aws-deploy" {
  name = local.project_name
}

resource "aws_apprunner_auto_scaling_configuration_version" "aws-deploy" {
  auto_scaling_configuration_name = local.project_name # scale between 1-5 containers
  min_size                        = 1
  max_size                        = 2
}

resource "aws_apprunner_service" "aws-deploy" {
  service_name                   = local.project_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.aws-deploy.arn

  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"
      }
      image_identifier      = "${aws_ecr_repository.aws-deploy.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true

    authentication_configuration {
      access_role_arn = aws_iam_role.aws-deploy.arn
    }
  }

  tags = {
    Name = local.project_name
  }
}