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
  response_templates = {
    "application/json" = <<EOF
 [
    #if( $input.params('family') == "red" )
       {
          "description_str":"Xanya is the fire tribe's banished general. She broke ranks and has been wandering ever since.",
          "dragon_name_str":"Xanya",
          "family_str":"red",
          "location_city_str":"las vegas",
          "location_country_str":"usa",
          "location_neighborhood_str":"e clark ave",
          "location_state_str":"nevada"
       }, {
          "description_str":"Eislex flies with the fire sprites. He protects them and is their guardian.",
          "dragon_name_str":"Eislex",
          "family_str":"red",
          "location_city_str":"st. cloud",
          "location_country_str":"usa",
          "location_neighborhood_str":"breckenridge ave",
          "location_state_str":"minnesota"      }
    #elseif( $input.params('family') == "blue" )
       {
          "description_str":"Protheus is a wise and ancient dragon that serves on the grand council in the sky world. He uses his power to calm those near him.",
          "dragon_name_str":"Protheus",
          "family_str":"blue",
          "location_city_str":"brandon",
          "location_country_str":"usa",
          "location_neighborhood_str":"e morgan st",
          "location_state_str":"florida"
       }
    #elseif( $input.params('dragonName') == "Atlas" )
       {
          "description_str":"From the northern fire tribe, Atlas was born from the ashes of his fallen father in combat. He is fearless and does not fear battle.",
          "dragon_name_str":"Atlas",
          "family_str":"red",
          "location_city_str":"anchorage",
          "location_country_str":"usa",
          "location_neighborhood_str":"w fireweed ln",
          "location_state_str":"alaska"
       }
    #else
       {
          "description_str":"From the northern fire tribe, Atlas was born from the ashes of his fallen father in combat. He is fearless and does not fear battle.",
          "dragon_name_str":"Atlas",
          "family_str":"red",
          "location_city_str":"anchorage",
          "location_country_str":"usa",
          "location_neighborhood_str":"w fireweed ln",
          "location_state_str":"alaska"
       },
       {
          "description_str":"Protheus is a wise and ancient dragon that serves on the grand council in the sky world. He uses his power to calm those near him.",
          "dragon_name_str":"Protheus",
          "family_str":"blue",
          "location_city_str":"brandon",
          "location_country_str":"usa",
          "location_neighborhood_str":"e morgan st",
          "location_state_str":"florida"
       },
       {
          "description_str":"Xanya is the fire tribe's banished general. She broke ranks and has been wandering ever since.",
          "dragon_name_str":"Xanya",
          "family_str":"red",
          "location_city_str":"las vegas",
          "location_country_str":"usa",
          "location_neighborhood_str":"e clark ave",
          "location_state_str":"nevada"
       },
       {
          "description_str":"Eislex flies with the fire sprites. He protects them and is their guardian.",
          "dragon_name_str":"Eislex",
          "family_str":"red",
          "location_city_str":"st. cloud",
          "location_country_str":"usa",
          "location_neighborhood_str":"breckenridge ave",
          "location_state_str":"minnesota"
       }
    #end
 ]
EOF
  }
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
  http_method = aws_api_gateway_method.post.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = aws_api_gateway_rest_api.aws-deploy.id
  type        = "MOCK"
  request_templates = {
    "application/json" : <<EOF
{"statusCode": 200}
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
