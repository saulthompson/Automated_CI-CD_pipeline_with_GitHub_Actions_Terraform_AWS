resource "aws_iam_role" "github_actions" {
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

resource "aws_iam_policy" "github_actions_policy" {
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
        Action   = ["cloudfront:*", "lambda:*"]
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
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

resource "aws_iam_policy" "github_s3_upload" {
  name = "GitHubS3UploadPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:ListBucket"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_s3_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_s3_upload.arn
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_thumbprint]
}