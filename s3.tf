<<<<<<< HEAD
resource "aws_s3_bucket" "this" {
  bucket = "naya-2026"
  acl    = "private"

  tags = {
    Name = "naya-2026"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
=======
# ==================== S3 Bucket - Raw Data ====================
resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-${var.environment}"

  tags = {
    Name        = "${var.project_name}-raw-data-${var.environment}"
    Purpose     = "Store raw YouTube analytics data"
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322

  versioning_configuration {
    status = "Enabled"
  }
}
<<<<<<< HEAD
=======

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    id     = "archive-old-data"
    status = "Enabled"

    # 30일 후 Glacier로 전환
    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    # 90일 후 Deep Archive로 전환
    transition {
      days          = 90
      storage_class = "DEEP_ARCHIVE"
    }

    # 365일 후 삭제
    expiration {
      days = 365
    }
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==================== S3 Bucket - Website ====================
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${var.environment}"

  tags = {
    Name    = "${var.project_name}-website-${var.environment}"
    Purpose = "Host static website"
  }
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public Access for Website
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy - Allow Public Read
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Encryption for Website
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
