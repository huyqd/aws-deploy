variable "batch_type" {
  type        = string
  description = "AWS Batch Compute Type ('ec2', 'fargate')"
  default     = "ec2"
}

variable "compute_environment_desired_vcpus" {
  type        = number
  description = "Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
}

variable "compute_environment_instance_types" {
  type        = list(string)
  description = "The instance types for the compute environment as a comma-separated list"
}

variable "compute_environment_max_vcpus" {
  type        = number
  description = "Maximum VCPUs for Batch Compute Environment [16-96]"
}

variable "compute_environment_min_vcpus" {
  type        = number
  description = "Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
}

variable "compute_environment_allocation_strategy" {
  type        = string
  default     = "BEST_FIT"
  description = "Allocation strategy for Batch Compute environment (BEST_FIT, BEST_FIT_PROGRESSIVE, SPOT_CAPACITY_OPTIMIZED)"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids to launch compute environment in"
}

variable "compute_environment_name" {
  type        = string
  description = ""
}

variable "batch_execution_role_arn" {
  type        = string
  description = "Role assigned to AWS Batch to call / create other AWS resources"
}

variable "ecs_instance_role_arn" {
  type = string
}

variable "enable_fargate_on_batch" {
  type = bool
}

variable "launch_template" {
  type = list(object({ id = string, latest_version = string }))
}

variable "security_group_ids" {
  type = list(string)
}
