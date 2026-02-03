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
  uri                     = aws_lambda_function.this.invoke_arn
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

############################
# Lambda 호출 권한 부여
############################
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

############################
# API 배포
############################
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
    aws_api_gateway_integration.analyze_lambda,
    aws_api_gateway_integration.analyze_options,
    aws_api_gateway_integration_response.analyze_options_200
  ]
}

############################
# 스테이지
############################
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.env
}

output "analyze_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/analyze"
}