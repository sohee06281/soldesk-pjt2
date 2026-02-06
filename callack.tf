resource "aws_iam_role" "callback" {
  name = "${var.project_name}-callback-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "callback" {
  function_name = "${var.project_name}-callback"
  role          = aws_iam_role.callback.arn
  runtime       = "python3.10"
  handler       = "lambda_ingest.lambda_handler"

  filename         = "naya-callback.zip"
  source_code_hash = filebase64sha256("${var.root_path}\\naya-callback.zip")

  timeout     = 30
  memory_size = 512

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id
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
      FRONTEND_BASE_URL  = "https://${aws_s3_bucket.frontend.bucket}.s3.${var.aws_region}.amazonaws.com/index.html"
      GOOGLE_CLIENT_ID  = var.google_client_id
      GOOGLE_CLIENT_SECRET  = var.google_client_secret
      REDIRECT_URI  = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.aws_region}.amazonaws.com/${var.env}/auth/google/callback"
    }
  }

  layers = [
    "arn:aws:lambda:ap-northeast-2:289050431231:layer:requests_layer:1",
    "arn:aws:lambda:ap-northeast-2:289050431231:layer:lambda_db_pg8000:1"
  ]

}

resource "aws_iam_role_policy" "callback_vpc" {
  name = "${var.project_name}-lambda-vpc-policy"
  role = aws_iam_role.callback.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-northeast-2:289050431231:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-northeast-2:289050431231:log-group:/aws/lambda/${var.project_name}-callback:*"
            ]
        },
        {
            "Sid": "AWSLambdaVPCAccessExecutionPermissions",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSubnets",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        }
    ]
  })
}




