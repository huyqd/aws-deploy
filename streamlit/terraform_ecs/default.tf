data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  service_name = "streamlit"

  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  environment  = "playground"
  project_name = "aws-deploy"

  vpc_cidr            = "10.1.0.0/16"
  private_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones  = ["eu-central-1a", "eu-central-1b"]

  container_port   = 8501
  cpu              = 256
  memory           = 1024
  healthcheck_path = "/_stcore/health"
  launch_type      = "FARGATE"

  hosted_zone        = "app-${local.environment}.dev"
  canonical_dns_name = "aws-deploy.app-${local.environment}.dev"
}

resource "aws_s3_bucket" "aws-deploy" {
  bucket = "${local.project_name}-${local.environment}"

}

resource "aws_ecr_repository" "aws-deploy" {
  name = local.project_name

  image_scanning_configuration {
    scan_on_push = false
  }
}
