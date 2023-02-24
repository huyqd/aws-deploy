resource "aws_api_gateway_rest_api" "aws-deploy" {
  name = local.project_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  parent_id   = aws_api_gateway_rest_api.aws-deploy.root_resource_id
  path_part   = "dragons"
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
}

resource "aws_api_gateway_method" "get" {
  #  authorization = "None"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito-authorizer.id
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.resource.id
  rest_api_id   = aws_api_gateway_rest_api.aws-deploy.id
}

resource "aws_api_gateway_integration" "get_integration" {
  http_method             = aws_api_gateway_method.get.http_method
  resource_id             = aws_api_gateway_resource.resource.id
  rest_api_id             = aws_api_gateway_rest_api.aws-deploy.id
  integration_http_method = "POST"      // must be POST to invoke lambda
  type                    = "AWS_PROXY" // for lambda proxy
  uri                     = aws_lambda_function.listDragons.invoke_arn
}


resource "aws_api_gateway_method_response" "get_response" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.aws-deploy.id
  stage_name    = "prod"
}

resource "aws_api_gateway_model" "model" {
  rest_api_id  = aws_api_gateway_rest_api.aws-deploy.id
  name         = "dragonmodel"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Dragon",
  "type": "object",
  "properties": {
    "dragonName": { "type": "string" },
    "description": { "type": "string" },
    "family": { "type": "string" },
    "city": { "type": "string" },
    "country": { "type": "string" },
    "state": { "type": "string" },
    "neighborhood": { "type": "string" },
    "reportingPhoneNumber": { "type": "string" },
    "confirmationRequired": { "type": "boolean" }
  }
}
EOF
}

resource "aws_api_gateway_method" "post" {
  #  authorization        = "None"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito-authorizer.id
  http_method          = "POST"
  resource_id          = aws_api_gateway_resource.resource.id
  rest_api_id          = aws_api_gateway_rest_api.aws-deploy.id
  request_validator_id = aws_api_gateway_request_validator.request_validator.id
  request_models       = { "application/json" : aws_api_gateway_model.model.name }
}

resource "aws_api_gateway_request_validator" "request_validator" {
  name                  = "validator"
  rest_api_id           = aws_api_gateway_rest_api.aws-deploy.id
  validate_request_body = true
}

resource "aws_api_gateway_integration" "post_integration" {
  http_method             = aws_api_gateway_method.post.http_method
  resource_id             = aws_api_gateway_resource.resource.id
  rest_api_id             = aws_api_gateway_rest_api.aws-deploy.id
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${local.region}:states:action/StartExecution"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.gw-role.arn

  request_templates = {
    "application/json" = <<EOF
#set($data = $input.path('$'))

#set($input = " {
  ""dragon_name_str"" : ""$data.dragonName"",
  ""description_str"" : ""$data.description"",
  ""family_str"" : ""$data.family"",
  ""location_city_str"" : ""$data.city"",
  ""location_country_str"" : ""$data.country"",
  ""location_state_str"" : ""$data.state"",
  ""location_neighborhood_str"" : ""$data.neighborhood"",
  ""reportingPhoneNumber"" : ""$data.reportingPhoneNumber"",
  ""confirmationRequired"" : $data.confirmationRequired}")

{
    "input": "$util.escapeJavaScript($input).replaceAll("\\'", "'")",
    "stateMachineArn": "${aws_sfn_state_machine.aws-deploy.arn}"
}
EOF
  }
}


resource "aws_api_gateway_method_response" "post_response" {
  http_method = aws_api_gateway_method.post.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method" "options" {
  authorization = "None"
  rest_api_id   = aws_api_gateway_rest_api.aws-deploy.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Credentials" = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
