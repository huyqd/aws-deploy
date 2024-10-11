resource "aws_s3_bucket" "metaflow" {
  bucket              = var.bucket_name
  object_lock_enabled = true
  force_destroy       = var.force_destroy_s3_bucket

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.metaflow.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
