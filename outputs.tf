output "vpc_id" {
  value = aws_vpc.this.id
}

output "rds_endpoint" {
  value = aws_db_instance.this.address
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.key_name}-bastion.pem ec2-user@${aws_instance.bastion.public_ip}"
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}
