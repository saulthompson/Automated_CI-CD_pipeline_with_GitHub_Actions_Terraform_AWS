terraform {}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

import {
  to = aws_s3_bucket.tfstate
  id = "tf-${var.account_id}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tf-${var.account_id}"
}

module "github_actions_integration" {
  source = "./modules/github_actions_integration"
  github_repo = var.github_repo
}

module "cloudfront" {
  source = "./modules/cloudfront"
}

module "website_s3" {
  source = "./modules/website_s3"
}