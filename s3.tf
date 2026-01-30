resource "aws_s3_bucket" "this" {
  bucket = "naya-2026"
  acl    = "private"

  tags = {
    Name = "naya-2026"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
