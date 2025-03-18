#!/bin/bash

GH_USERNAME=$(gh api user --jq '.login') || { echo "Error: Failed to get GitHub username"; exit 1; }
echo "GH_USERNAME=$GH_USERNAME"

REPO_URL=$(git config --get remote.origin.url) || { echo "Error: Failed to get remote.origin.url"; exit 1; }
echo "REPO_URL=$REPO_URL"

REPO_NAME=$(echo "$REPO_URL" | sed 's#.*/##; s#.git##' | tr -d '[:space:]\r') || { echo "Error: Failed to parse repo name"; exit 1; }
echo "REPO_NAME=$REPO_NAME"

[ -z "$REPO_NAME" ] && { echo "Error: REPO_NAME is empty"; exit 1; }

REPO="${GH_USERNAME}/${REPO_NAME}"
echo "REPO=$REPO""
IAM_USER="gha-bootstrap-user"

# Create IAM user
aws iam create-user --user-name "$IAM_USER"

# Attach AdministratorAccess policy
aws iam attach-user-policy --user-name "$IAM_USER" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Generate access key and capture output
ACCESS_KEY_JSON=$(aws iam create-access-key --user-name "$IAM_USER")

# Extract AccessKeyId and SecretAccessKey
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_JSON" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_JSON" | jq -r '.AccessKey.SecretAccessKey')

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Set GitHub Secrets using GitHub CLI
gh secret set AWS_ACCESS_KEY_ID --repo "$REPO" --body "$ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --repo "$REPO" --body "$SECRET_ACCESS_KEY"
gh secret set AWS_ACCOUNT_ID --repo "$REPO" --body "$ACCOUNT_ID"
gh secret set S3_BUCKET --repo "$REPO" --body "my-static-site"

echo "GitHub Secrets set successfully for repo: $REPO"
echo "AWS_ACCESS_KEY_ID: $ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: [hidden]"
echo "AWS_ACCOUNT_ID: $ACCOUNT_ID"
echo "S3_BUCKET: my-static-site"
