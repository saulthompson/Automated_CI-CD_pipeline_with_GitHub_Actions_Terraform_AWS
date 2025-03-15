resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.bucket_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = ""  # Empty for public buckets; use OAI if private
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
