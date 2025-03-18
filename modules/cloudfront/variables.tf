variable "bucket_name" {
  description = "S3 bucket name for CloudFront origin"
  type        = string
}

variable "bucket_regional_domain_name" { 
  type = string 
}

variable "account_id" { 
  type = string 
}

variable "website_password" {
  type = string
}

variable "website_username" {
  type = string
}

variable "oai_id" {
  type = string
}