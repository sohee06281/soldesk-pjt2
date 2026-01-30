<<<<<<< HEAD
output "vpc_id" {
  value = aws_vpc.this.id
}

output "rds_endpoint" {
  value = aws_db_instance.this.address
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.key_name}-bastion.pem ec2-user@${aws_instance.bastion.public_ip}"
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}
=======
# ==================== VPC Outputs ====================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private[*].id
}

# ==================== RDS Outputs ====================
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS address (without port)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

# ==================== S3 Outputs ====================
output "s3_raw_data_bucket" {
  description = "S3 raw data bucket name"
  value       = aws_s3_bucket.raw_data.id
}

output "s3_raw_data_arn" {
  description = "S3 raw data bucket ARN"
  value       = aws_s3_bucket.raw_data.arn
}

output "s3_website_bucket" {
  description = "S3 website bucket name"
  value       = aws_s3_bucket.website.id
}

output "s3_website_url" {
  description = "S3 website URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

# ==================== Lambda Outputs ====================
output "lambda_fetch_and_analyze_arn" {
  description = "Lambda fetchAndAnalyze ARN"
  value       = aws_lambda_function.fetch_and_analyze.arn
}

output "lambda_fetch_and_analyze_name" {
  description = "Lambda fetchAndAnalyze function name"
  value       = aws_lambda_function.fetch_and_analyze.function_name
}

output "lambda_get_results_arn" {
  description = "Lambda getResults ARN"
  value       = aws_lambda_function.get_results.arn
}

output "lambda_get_results_name" {
  description = "Lambda getResults function name"
  value       = aws_lambda_function.get_results.function_name
}

# ==================== API Gateway Outputs ====================
output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL with stage"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}"
}

# ==================== Secrets Manager Outputs ====================
output "youtube_api_secret_arn" {
  description = "YouTube API Secret ARN"
  value       = aws_secretsmanager_secret.youtube_api.arn
}

output "db_credentials_secret_arn" {
  description = "DB Credentials Secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

# ==================== AWS Account Info ====================
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

# ==================== Connection Info ====================
output "connection_info" {
  description = "Quick connection information"
  value = {
    rds_connection = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${aws_db_instance.main.db_name}"
    api_base_url   = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}"
    website_url    = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
  }
}
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
