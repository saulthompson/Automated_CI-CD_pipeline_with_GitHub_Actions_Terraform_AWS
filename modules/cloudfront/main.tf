# Lambda@Edge for Basic Auth
resource "local_file" "lambda_auth_rendered" {
  content = templatefile("${path.module}/lambda/index.js.tpl", {
    basic_user     = var.website_username
    basic_password = var.website_password
  })
  filename = "${path.module}/lambda/index.js"
}

resource "aws_lambda_function" "basic_auth" {
  function_name    = "basic-auth-${var.account_id}"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "${path.module}/lambda.zip"
  source_code_hash = base64sha256(templatefile("${path.module}/lambda/index.js.tpl", {
    basic_user     = var.website_username
    basic_password = var.website_password
  }))
  publish          = true
}

resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.basic_auth.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.cdn.arn
  qualifier     = aws_lambda_function.basic_auth.version
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role-${var.account_id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"] }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_logs" {
  name   = "lambda-logs-${var.account_id}"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${var.oai_id}"
    }
  }
  enabled             = true
  default_root_object = "web/index.html"
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.basic_auth.qualified_arn
    }
  }
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  depends_on = [aws_lambda_function.basic_auth]
}