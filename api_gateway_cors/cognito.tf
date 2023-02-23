resource "aws_cognito_user_pool" "pool" {
  name = local.project_name
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = local.project_name
  user_pool_id = aws_cognito_user_pool.pool.id
  callback_urls = [
    "https://aws-deploy-playground.s3.eu-central-1.amazonaws.com/dragonsapp/index.html"
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

resource "random_id" "server" {
  byte_length = 8
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "${local.environment}-${random_id.server.hex}"
  user_pool_id = aws_cognito_user_pool.pool.id
}


resource "aws_api_gateway_authorizer" "cognito-authorizer" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.aws-deploy.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.pool.arn]
  identity_source = "method.request.header.Authorization"
}
