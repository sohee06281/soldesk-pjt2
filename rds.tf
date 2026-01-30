<<<<<<< HEAD
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet"
    subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet"
  }
}


resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  port           = 5432

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name

  vpc_security_group_ids = [aws_security_group.rds.id]
  

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-postgres"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }


  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}
=======
# ==================== DB Subnet Group ====================
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-${var.environment}"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-${var.environment}"
  }
}

# ==================== RDS PostgreSQL ====================
resource "aws_db_instance" "main" {
  # 식별자
  identifier = "${var.project_name}-db-${var.environment}"

  # 엔진 설정
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  
  # 스토리지
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # 데이터베이스 설정
  db_name  = "cloudstream"
  username = var.db_username
  password = var.db_password
  port     = 5432

  # 네트워크
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true  # 개발용 (프로덕션에선 false)

  # 가용성
  multi_az               = false  # 비용 절감 (프로덕션에선 true)
  availability_zone      = var.availability_zones[0]

  # 백업
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  # 삭제 보호
  deletion_protection       = false  # 개발용 (프로덕션에선 true)
  skip_final_snapshot      = true   # 개발용 (프로덕션에선 false)
  final_snapshot_identifier = "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # 모니터링
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn

  # 파라미터 그룹
  parameter_group_name = aws_db_parameter_group.main.name

  # 성능 인사이트 (선택사항)
  performance_insights_enabled = false  # 비용 절감

  # 자동 마이너 버전 업그레이드
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-db-${var.environment}"
  }

  # Terraform이 비밀번호 변경을 무시하도록 설정
  lifecycle {
    ignore_changes = [password]
  }
}

# ==================== DB Parameter Group ====================
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-db-params-${var.environment}"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  tags = {
    Name = "${var.project_name}-db-params-${var.environment}"
  }
}

# ==================== RDS Monitoring IAM Role ====================
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-rds-monitoring-role-${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
