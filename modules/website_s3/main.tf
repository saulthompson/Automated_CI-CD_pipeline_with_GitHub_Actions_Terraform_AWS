terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [
          aws.us_east_1,
      ]
    }
  }
}

resource "aws_s3_bucket" "website" {
  bucket   = "my-static-site-${var.account_id}"
  provider = aws.us_east_1
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true  # Block new public ACLs
  block_public_policy     = true  # Block new public policies
  ignore_public_acls      = true  # Ignore existing public ACLs
  restrict_public_buckets = true  # Restrict access to only authorized entities
  provider                = aws.us_east_1
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment  = "OAI for my-static-site-${var.account_id}"
  provider = aws.us_east_1
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-static-site-${var.account_id}/*"
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.account_id}:role/GitHubActionsRole" }
        Action    = ["s3:ListBucket", "s3:PutObject", "s3:DeleteObject"]
        Resource  = [
          "arn:aws:s3:::my-static-site-${var.account_id}",
          "arn:aws:s3:::my-static-site-${var.account_id}/*"
        ]
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.website, aws_cloudfront_origin_access_identity.oai]
  provider   = aws.us_east_1
}