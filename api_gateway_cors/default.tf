data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  environment  = "playground"
  project_name = "aws-deploy"

  vpc_cidr            = "10.1.0.0/16"
  private_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones  = ["eu-central-1a", "eu-central-1b"]

}

resource "aws_s3_bucket" "aws-deploy" {
  bucket = "${local.project_name}-${local.environment}"
}

resource "aws_ssm_parameter" "bucket" {
  name      = "dragon_data_bucket_name"
  type      = "String"
  value     = aws_s3_bucket.aws-deploy.id
  overwrite = true
}

resource "aws_ssm_parameter" "file" {
  name      = "dragon_data_file_name"
  type      = "String"
  value     = "dragon_stats_one.txt"
  overwrite = true
}
