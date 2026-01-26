output "alb_dns" {
  value = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "s3_raw_bucket" {
  value = aws_s3_bucket.raw.bucket
}
