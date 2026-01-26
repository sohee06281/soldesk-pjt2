resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-raw-bucket"

  tags = {
    Name = "raw-data-bucket"
  }
}
