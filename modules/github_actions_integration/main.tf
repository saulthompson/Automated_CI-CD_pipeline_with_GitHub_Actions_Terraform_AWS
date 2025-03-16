terraform {
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

variable "github_repo" { type = string }
variable "account_id" { type = string }
variable "bucket_arn" { type = string }

# Reference existing role if it exists, otherwise create it
data "aws_iam_role" "github_actions_existing" {
  name = "GitHubActionsRole"
}

resource "aws_iam_role" "github_actions" {
  count = length(data.aws_iam_role.github_actions_existing) == 0 ? 1 : 0  # Create only if not found
  name  = "GitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com" }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = { StringEquals = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main" } }
      }
    ]
  })
}

# Reference existing policy if it exists, otherwise create it
data "aws_iam_policy" "github_actions_policy_existing" {
  name = "GitHubActionsPolicy"
}

resource "aws_iam_policy" "github_actions_policy" {
  count = length(data.aws_iam_policy.github_actions_policy_existing) == 0 ? 1 : 0  # Create only if not found
  name  = "GitHubActionsPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*", "iam:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetDistribution", "cloudfront:UpdateDistribution"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole", "sts:GetCallerIdentity"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = length(data.aws_iam_role.github_actions_existing) == 0 ? aws_iam_role.github_actions[0].name : data.aws_iam_role.github_actions_existing.name
  policy_arn = length(data.aws_iam_policy.github_actions_policy_existing) == 0 ? aws_iam_policy.github_actions_policy[0].arn : data.aws_iam_policy.github_actions_policy_existing.arn
}

resource "aws_iam_policy" "github_s3_upload" {
  name = "GitHubS3UploadPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:ListBucket"]
      Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_s3_attach" {
  role       = length(data.aws_iam_role.github_actions_existing) == 0 ? aws_iam_role.github_actions[0].name : data.aws_iam_role.github_actions_existing.name
  policy_arn = aws_iam_policy.github_s3_upload.arn
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}