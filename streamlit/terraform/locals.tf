locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  environment  = "playground"
  project_name = "aws-deploy"
  service_name = "streamlit"

  public_subnets  = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
#  private_subnets = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}
