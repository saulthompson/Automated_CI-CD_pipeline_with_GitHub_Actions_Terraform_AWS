# Automated CI/CD pipeline for deploying password-protected static websites with AWS Cloudfront

# Approach

My basic idea is to fully automate the whole process of deploying and redeploying a static website with GitHub Actions from scratch, including bootstrapping of an S3 bucket for the terraform backend.

I configured OpenID Connect to allow GHA to assume a temporary IAM role and interact with AWS resources.
On the first bootstrapping run, AWS credentials must be stored as secrets GitHub Secrets. However, in subsequent runs, these credentials are no longer needed thanks to the OIDC setup.

Whenever a change is pushed to the github repo, the GitHub Actions workflow is triggered, which causes any new content in the web/ directory to be synced to an S3 bucket where the website is hosted.

Cloudfront is used together with the website-hosting S3 bucket to provide a lambda edge function which implements user authentication using Basic Auth.

# A Low-cost Soltion

-  The Cloudfront Lambda Edge function leverages edge caching and serverless functions
-  GHA workflows are free for up to 2,000 minutes per month
-  Teardown measures throughout the workflow prevent orphaned AWS resources from generating hidden costs


# Instructions

1. Clone this repository to your local IDE
2. Add any static web content of your choosing to the web/ directory
3. Create a GitHub repo and set it as the remote for this repository.
4. Set GitHub Secrets values for the inital run, including:
  - AWS_ACCOUNT_ID
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - S3_BUCKET (choose any value you like)
  - WEBSITE_USERNAME
  - WEBSITE_PASSWORD
5. Push your repo to GitHub
6. Find your cloudfront URL in the GitHub Actions output, under "protected URL output"
7. a hash of the credentials is automatically set as the Authorization header value for all future requests to this URL within the same browser session, allowing you to navigate to the URL in different tabs or windows without having to re-enter credentials.
8. After the first run, delete all secrets from GitHub Secrets for security. All subsequent runs will automatically handle authentication between GitHub Actions and AWS using OIDC

# Maintainability

I made every effort to parameterize credentials and other variable values for maintainability.

Nonetheless, developers should be aware of some changes that might need to be implemented in the future:

1. It might be necessary to update github's thumbprint-list for the OIDC setup in the github_actions_integration module.
 
2. Care should be taken to remove long-lived aws credentials from github secrets after bootstrapping.

3. It might be necessary to update the template file relative path in modules/cloudfront/main.tf in different environments. I made a local version of lambda.zip for use in local development. In the GHA workflow, the index.js.tftlp file is zipped dynamically.

# Security

I implemented OpenID Connect, which is more secure in the long run than relying on AWS credentials stored indefinitely in GitHub Secrets.

In general, I aim to follow the principle of least permissions. However, for the purposes of this project, I just universal permissions in various places in the interest of time. In production, these would need to be tightened up.

