resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}-db-secret34"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "youtube_api" {
  name                    = "${var.project_name}-youtube-api-key"
  description             = "YouTube API Key for CloudStream Analytics"
  recovery_window_in_days = 0  # 즉시 삭제 가능 (개발용)

  tags = {
    Name = "${var.project_name}-youtube-api-youtube_api_key"
  }
}

resource "aws_secretsmanager_secret_version" "youtube_api" {
  secret_id = aws_secretsmanager_secret.youtube_api.id
  
  secret_string = jsonencode({
    api_key = var.youtube_api_key
  })
}