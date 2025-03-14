terraform {
  backend "s3" {
    key    = "tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

import {
  to = aws_s3_bucket.tfstate
  id = "tf-${local.account_id}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tf-${local.account_id}"
}

module "github_actions_integration" {
  source = "./modules/github_actions_integration"
}

module "cloudfront" {
  source = "./modules/cloudfront"
}

module "website_s3" {
  source = "./modules/website_s3"
}