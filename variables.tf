variable "aws_region" {
<<<<<<< HEAD
  default = "ap-northeast-2"
}

variable "key_name" {
  default = "naya"
  description = "EC2 Key Pair name"
  type        = string

}

variable "root_path" {
  default = "C:\\leesomin_wkspace\\soldesk-pjt2"
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
=======
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloudstream"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "cloudstream_admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
  }
}

variable "youtube_api_key" {
  description = "YouTube API Key"
  type        = string
  sensitive   = true
}

<<<<<<< HEAD
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



=======
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
