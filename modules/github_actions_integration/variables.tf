variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
}

variable "account_id" {
  type = string
}

variable "bucket_arn" {
  type        = string
}

variable "github_thumbprint" {
  default = "6938fd4d98bab03faadb97b34396831e3780aea1"
  description = "OIDC thumbprint for GitHub Actions"
}
