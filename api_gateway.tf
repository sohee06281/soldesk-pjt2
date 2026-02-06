resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-api"
}


resource "aws_api_gateway_resource" "analyze" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "analyze"
}


resource "aws_api_gateway_method" "analyze_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.analyze.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "analyze_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.analyze.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}



############################
# Lambda 연동 (Proxy)
############################
resource "aws_api_gateway_integration" "analyze_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analyze.id
  http_method = aws_api_gateway_method.analyze_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "analyze_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analyze.id
  http_method = aws_api_gateway_method.analyze_options.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "analyze_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analyze.id
  http_method = aws_api_gateway_method.analyze_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "analyze_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analyze.id
  http_method = aws_api_gateway_method.analyze_options.http_method
  status_code = aws_api_gateway_method_response.analyze_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

############################################
# /auth
############################################
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "auth"
}

############################################
# /auth/google
############################################
resource "aws_api_gateway_resource" "auth_google" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "google"
}

############################################
# /auth/google/callback
############################################
resource "aws_api_gateway_resource" "auth_google_callback" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.auth_google.id
  path_part   = "callback"
}

resource "aws_api_gateway_method" "auth_google_callback_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.auth_google_callback.id
  http_method   = "GET"
  authorization = "NONE"
}

############################################
# /auth/google/callback → Lambda (GET)
############################################
resource "aws_api_gateway_integration" "auth_google_callback_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.auth_google_callback.id
  http_method = aws_api_gateway_method.auth_google_callback_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.callback.invoke_arn
}

############################################
# Lambda 호출 권한
############################################
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/analyze"
}

resource "aws_lambda_permission" "apigw_callback" {
  statement_id  = "AllowAPIGatewayInvokeCallback"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.callback.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/GET/auth/google/callback"
}

############################################
# API 배포
############################################
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
    aws_api_gateway_integration.analyze_lambda,
    aws_api_gateway_integration.analyze_options,
    aws_api_gateway_integration_response.analyze_options_200,
    aws_api_gateway_integration.auth_google_callback_lambda
  ]
}

############################################
# Stage
############################################
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.env
}

############################################
# Outputs
############################################
output "analyze_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/analyze"
}

output "google_callback_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/auth/google/callback"
}