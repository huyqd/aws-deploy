data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  resource_prefix = length(var.resource_prefix) > 0 ? "${var.resource_prefix}-" : ""
  resource_suffix = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : ""

  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id

  metadata_service_container_image = "netflixoss/metaflow_metadata_service"
  ui_static_container_image        = "public.ecr.aws/outerbounds/metaflow_ui"
}
