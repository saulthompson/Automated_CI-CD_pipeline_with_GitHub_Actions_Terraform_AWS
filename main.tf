terraform {
  backend "s3" {} # partial backend config completed using cli args on terraform apply
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

import {
  to = aws_s3_bucket.tfstate
  id = "tfs-${var.account_id}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tfs-${var.account_id}"
}

module "cloudfront" {
  source                     = "./modules/cloudfront"
  bucket_name                = module.website_s3.bucket_name
  bucket_regional_domain_name = module.website_s3.bucket_regional_domain_name
  account_id                 = var.account_id
  oai_id                     = module.website_s3.oai_iam_arn != "" ? reverse(split("/", module.website_s3.oai_iam_arn))[0] : ""
  website_username           = var.website_username
  website_password           = var.website_password
}

module "website_s3" {
  source = "./modules/website_s3"
  account_id = var.account_id
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

output "protected_url" {
  value = module.cloudfront.cloudfront_url
}