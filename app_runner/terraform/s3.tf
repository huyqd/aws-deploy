
resource "aws_s3_bucket" "aws-deploy" {
  bucket = "aws-deploy-${local.environment}"
}


