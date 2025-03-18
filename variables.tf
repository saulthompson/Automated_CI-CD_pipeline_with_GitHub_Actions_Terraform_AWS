variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
}

variable "website_username" {
  type = string
}

variable "website_password" {
  type = string
}