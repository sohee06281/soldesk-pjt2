resource "aws_s3_bucket" "lambda" {
  bucket = "naya-lambda-2026"
  acl    = "private"

  tags = {
    Name = "naya-lambda-2026"
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = "naya-frontend-2026"
  acl    = "private"

  tags = {
    Name = "naya-frontend-2026"
  }
}

resource "aws_s3_bucket_versioning" "lambda" {
  bucket = aws_s3_bucket.lambda.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

