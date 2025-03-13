terraform {
  backend "s3" {
    key = "tfstate"
  }
}

provider "aws" {}


# Below we import the state bucket made with GHA... into our own state
# Just a quick check that everything works

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
