resource "aws_s3_bucket" "tfstate" {
  bucket = "tf-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "tfstate_bucket_policy" {
  bucket = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        },
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::tf-${var.account_id}",
          "arn:aws:s3:::tf-${var.account_id}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate_lifecycle" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}