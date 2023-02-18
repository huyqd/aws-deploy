resource "aws_s3_bucket" "aws-deploy" {
  bucket = "${local.project_name}-${local.environment}"
}


resource "aws_ecr_repository" "aws-deploy" {
  name = local.project_name

  image_scanning_configuration {
    scan_on_push = false
  }
}