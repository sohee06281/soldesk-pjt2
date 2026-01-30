<<<<<<< HEAD
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
=======
# ==================== Secrets Manager - YouTube API Key ====================
resource "aws_secretsmanager_secret" "youtube_api" {
  name                    = "${var.project_name}-youtube-api-key-${var.environment}"
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
  description             = "YouTube API Key for CloudStream Analytics"
  recovery_window_in_days = 0  # 즉시 삭제 가능 (개발용)

  tags = {
<<<<<<< HEAD
    Name = "${var.project_name}-youtube-api-youtube_api_key"
=======
    Name = "${var.project_name}-youtube-api-key-${var.environment}"
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
  }
}

resource "aws_secretsmanager_secret_version" "youtube_api" {
  secret_id = aws_secretsmanager_secret.youtube_api.id
  
  secret_string = jsonencode({
    api_key = var.youtube_api_key
  })
<<<<<<< HEAD
=======
}

# ==================== Secrets Manager - DB Credentials ====================
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials-${var.environment}"
  description             = "RDS PostgreSQL credentials"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-db-credentials-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.address
    port     = 5432
    dbname   = aws_db_instance.main.db_name
    engine   = "postgres"
  })
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
}