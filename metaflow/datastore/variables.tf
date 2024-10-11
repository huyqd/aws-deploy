variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t4g.small"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "16"
}

variable "db_name" {
  type        = string
  description = "Name of PostgresQL database for Metaflow service."
  default     = "metaflow"
}

variable "db_username" {
  type        = string
  description = "PostgresQL username; defaults to 'metaflow'"
  default     = "metaflow"
}

variable "force_destroy_s3_bucket" {
  type        = bool
  description = "Empty S3 bucket before destroying via terraform destroy"
  default     = false
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
}

variable "metaflow_vpc_id" {
  type        = string
  description = "ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix given to all AWS resources to differentiate between environment and workspace"
}

variable "tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for availability zone redundancy"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store data"
}
