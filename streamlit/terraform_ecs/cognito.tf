#resource "aws_cognito_user_pool" "aws-deploy" {
#  name = local.service_name
#  password_policy {
#    minimum_length    = 6
#    require_lowercase = false
#    require_numbers   = false
#    require_symbols   = false
#    require_uppercase = false
#  }
#}
#
#resource "aws_cognito_user_pool_client" "aws-deploy" {
#  name            = local.service_name
#  generate_secret = true
#  user_pool_id    = aws_cognito_user_pool.aws-deploy.id
#  callback_urls = [
#    "https://${aws_lb.aws-deploy.dns_name}",
#    "https://${aws_lb.aws-deploy.dns_name}/oauth2/idpresponse",
#  ]
#  allowed_oauth_flows_user_pool_client = true
#  allowed_oauth_flows                  = ["code", "implicit"]
#  allowed_oauth_scopes                 = ["email", "openid"]
##  supported_identity_providers         = ["COGNITO", aws_cognito_identity_provider.google.provider_name]
#  supported_identity_providers         = ["COGNITO"]
#}
#
#resource "aws_cognito_user_pool_domain" "aws-deploy" {
#  domain       = "${local.service_name}-${local.environment}-1234567890"
#  user_pool_id = aws_cognito_user_pool.aws-deploy.id
#}
#
#resource "aws_cognito_identity_provider" "google" {
#  user_pool_id  = aws_cognito_user_pool.aws-deploy.id
#  provider_name = "Google"
#  provider_type = "Google"
#
#  provider_details = {
#    #      # Add these strings to Authorised redirect URIs:
#    #      # https://DNS/oauth2/idpresponse
#    #      # https://CNAME/oauth2/idpresponse
#    #      # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html
#    authorize_scopes = "email"
#    client_id        = ""
#    client_secret    = ""
#  }
#
#  attribute_mapping = {
#    email    = "email"
#  }
#}
