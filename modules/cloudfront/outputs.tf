output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cwd_check" {
  value = "${path.module}"
}