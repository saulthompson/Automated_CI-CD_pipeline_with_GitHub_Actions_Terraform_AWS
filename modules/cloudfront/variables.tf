variable "bucket_name" {
  description = "S3 bucket name for CloudFront origin"
  type        = string
}

variable "bucket_regional_domain_name" { 
  type = string 
  default     = "${var.bucket_name}.s3.us-east-1.amazonaws.com"
}

variable "account_id" { 
  type = string 
}

variable "website_password" {
  type    = string
  default = "password"
}

variable "website_username" {
  type    = string
  default = "user"
}

variable "oai_id" {
  type = string
}