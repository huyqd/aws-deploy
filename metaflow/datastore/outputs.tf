output "METAFLOW_DATATOOLS_S3ROOT" {
  value       = "s3://${aws_s3_bucket.metaflow.bucket}/data"
  description = "Amazon S3 URL for Metaflow DataTools"
}

output "METAFLOW_DATASTORE_SYSROOT_S3" {
  value       = "s3://${aws_s3_bucket.metaflow.bucket}/metaflow"
  description = "Amazon S3 URL for Metaflow DataStore"
}

output "database_name" {
  value       = var.db_name
  description = "The database name"
}

output "database_password" {
  value       = random_password.db_password.result
  description = "The database password"
}

output "database_username" {
  value       = var.db_username
  description = "The database username"
}

output "rds_master_instance_endpoint" {
  value       = aws_db_instance.metaflow_datastore.endpoint
  description = "The database connection endpoint in address:port format"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.metaflow.arn
  description = "The ARN of the bucket we'll be using as blob storage"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.metaflow.bucket
  description = "The name of the bucket we'll be using as blob storage"
}
