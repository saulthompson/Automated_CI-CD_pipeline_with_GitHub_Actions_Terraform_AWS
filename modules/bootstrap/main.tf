provider "aws" {
  region = "${{ env.AWS_REGION }}"
}

data "aws_caller_identity" "current" {}

module "tfstate_s3" {
  source     = "../tfstate_s3"
  account_id = data.aws_caller_identity.current.account_id
}

module "github_actions_integration" {
  source      = "../github_actions_integration"
  account_id  = data.aws_caller_identity.current.account_id
  github_repo = "${{ github.repository }}"
  bucket_arn  = module.tfstate_s3.bucket_arn
}