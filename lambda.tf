resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "this" {
  function_name = "${var.project_name}-lambda"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.10"
  handler       = "lambda_ingest.lambda_handler"

  filename         = "lambda_ingest.py.zip"
  source_code_hash = filebase64sha256("${var.root_path}\\lambda_ingest.py.zip")

  timeout     = 30
  memory_size = 512

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_c.id
    ]

    security_group_ids = [
      aws_security_group.lambda-sg.id
    ]
  }

  environment {
    variables = {
      ENV            = var.env
      DB_HOST        = aws_db_instance.this.address
      DB_PORT        = "5432"
      DB_NAME        = var.db_name
      DB_USER        = var.db_username
      DB_PASSWORD    = var.db_password
      YOUTUBE_API_KEY  = var.youtube_api_key
      GOOGLE_CLIENT_ID  = var.google_client_id
      GOOGLE_CLIENT_SECRET  = var.google_client_secret
      GOOGLE_REFRESH_TOKEN  = var.google_refresh_token
      S3_BUCKET_RAW = aws_s3_bucket.lambda.bucket
    }
  }

  layers = [
    "arn:aws:lambda:ap-northeast-2:289050431231:layer:requests_layer:1",
    "arn:aws:lambda:ap-northeast-2:289050431231:layer:lambda_db_pg8000:1"
  ]

}

resource "aws_iam_role_policy" "lambda_vpc" {
  name = "${var.project_name}-lambda-vpc-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "LambdaVPCAccess"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Sid    = "LamdaS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "*"
      }
    ]
  })
}




