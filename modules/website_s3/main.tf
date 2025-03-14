resource "website_s3" "website" {
  bucket = "my-static-site-${local.account_id}"
}

resource "website_s3_policy" "public_read" {
  bucket = website_s3.website.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${website_s3.website.id}/*"
    }
  ]
}
POLICY
}