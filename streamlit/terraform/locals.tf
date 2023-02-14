locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  environment  = "playground"
  project_name = "aws-deploy"
  service_name = "streamlit"
}
