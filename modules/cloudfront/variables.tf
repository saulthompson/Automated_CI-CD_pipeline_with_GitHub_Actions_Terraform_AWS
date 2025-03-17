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