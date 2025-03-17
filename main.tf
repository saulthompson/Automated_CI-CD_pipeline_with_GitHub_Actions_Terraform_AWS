terraform {
  backend "s3" {}
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
}

module "website_s3" {
  source = "./modules/website_s3"
  account_id = var.account_id
}