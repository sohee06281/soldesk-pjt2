variable "aws_region" {
  default = "ap-northeast-2"
}

variable "key_name" {
  default = "naya"
  description = "EC2 Key Pair name"
  type        = string

}

variable "root_path" {
  default = "C:\\pjt\\soldesk-pjt2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_name" {
  type        = string
  description = "PostgreSQL database name"
}

variable "project_name"{
  type        = string
}

variable "db_username" {
  type        = string
  description = "PostgreSQL master username"
}

variable "db_password" {
  type        = string
  description = "PostgreSQL master password"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "DB password must be at least 8 characters."
  }
}

variable "youtube_api_key" {
  description = "YouTube API Key"
  type        = string
  sensitive   = true
}

variable "bastion_ami" {
  description = "AMI ID for bastion host"
  type        = string
}

variable "env" {
  type        = string
}

variable "google_client_id" {
  description = "Google Client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google Client Secret"
  type        = string
  sensitive   = true
}

variable "google_refresh_token" {
  description = "Google Refresh Token"
  type        = string
  sensitive   = true
}




