variable "region" {
  default = "ap-northeast-2"
}

variable "ec2_ami" {
  description = "EC2 AMI ID"
}

variable "db_user" {}
variable "db_password" {}

variable "project_name" {
  default = "youtube-analysis"
}
