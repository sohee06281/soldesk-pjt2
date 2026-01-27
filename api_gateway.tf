# ==================== API Gateway HTTP API ====================
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  description   = "CloudStream Analytics API"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["*"]
    max_age       = 300
  }

  tags = {
    Name = "${var.project_name}-api-${var.environment}"
  }
}

# ==================== API Gateway Stage ====================
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn

    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.error.message"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }

  tags = {
    Name = "${var.project_name}-api-stage-${var.environment}"
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway]
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-api-logs-${var.environment}"
  }
}

# ==================== Lambda Integration - fetchAndAnalyze ====================
resource "aws_apigatewayv2_integration" "fetch_and_analyze" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.fetch_and_analyze.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Route - POST /analyze/{videoId}
resource "aws_apigatewayv2_route" "analyze" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /analyze/{videoId}"
  target    = "integrations/${aws_apigatewayv2_integration.fetch_and_analyze.id}"
}

# Lambda Permission
resource "aws_lambda_permission" "fetch_and_analyze" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_and_analyze.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# ==================== Lambda Integration - getResults ====================
resource "aws_apigatewayv2_integration" "get_results" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_results.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Route - GET /results/{videoId}
resource "aws_apigatewayv2_route" "results" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /results/{videoId}"
  target    = "integrations/${aws_apigatewayv2_integration.get_results.id}"
}

# Lambda Permission
resource "aws_lambda_permission" "get_results" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_results.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}