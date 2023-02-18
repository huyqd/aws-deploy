data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  environment  = "playground"
  project_name = "aws-deploy"
  service_name = "streamlit"

  vpc_cidr            = "10.1.0.0/16"
  private_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones  = ["eu-central-1a", "eu-central-1b"]

  tsl_certificate_arn = "mycertificatearn"
  container_port      = 8501
  cpu                 = 256
  memory              = 1024
}
