# Saul's Cloud-Deployment-Challenge

# Approach

My basic idea is to fully automate the whole process with GitHub Actions, including bootstrapping of 
an S3 bucket for the terraform backend.

I configured OpenID Connect to allow GHA to assume a temporary IAM role and interact with AWS resources.
On the first bootstrapping run, AWS credentials must be stored as GitHub Secrets. However, in subsequent runs, the credentials are no longer needed thanks to the OIDC setup.

Whenever a change is pushed to the remote github repo, the workflow is triggered, and new content is synced to an S3 bucket where the website is hosted.

Cloudfront is used together with the website-hosting S3 bucket to provide a lambda edge function which implements user authentication using Basic Auth. The reason I used a lambda edge function with cloudfront, besides ease of use, is because of the cost-saving efficacy of cloudfront edge caching and serverless functions. Other cost-saving measures include the fact that GHA workflows are free for up to 2,000 minutes per month, and the teardown measures I implemented in the workflow, which prevent orphaned AWS resources.

# N.B. incomplete status of project

My approach relies on creating a cloudfront distribution. Unfortunately, my AWS account remains unverified, despite my attempts over the past days to complete the verification process. As a result, I am not authorized to create cloudfront distributions in my account, and have been unable to complete end-to-end testing. 

I considered an alternative solution, in which I would host the website in an S3 bucket without cloudfront, and implement credential authentication by adding a js file with an authentication flow interacting directly with the DOM to the web directory. I ultimately decided to leave my current, untested implementation, because it's a better solution overall, and in the interests of time.

# Instructions

Create a GitHub repo and set it as the remote for this repository.

All initial credentials are managed via GitHub Secrets. Make sure to set WEBSITE_PASSWORD and WEBSITE_USERNAME, as well as AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY in gh secrets.

Make any desired changes to the web directory, commit, and push to the remote. This will automatically trigger the GHA workflow, which will deploy all necessary architecture on AWS. 

Find the URL for your website in the AWS Cloudfront console.


# Maintainability

I made every effort to parameterize credentials and other variable values for maintainability.

Nonetheless, there are some changes that might need to be implemented in the future:

1. It might be necessary to update github's thumbprint-list for the OIDC setup in the github_actions_integration module.
 
2. Care should be taken to remove long-lived aws credentials from github secrets after bootstrapping.

3. It might be necessary to update the template file relative path in modules/cloudfront/main.tf in different environments. I made a local version of lambda.zip for use in local development. In the GHA workflow, the index.js.tlp file is zipped dynamically.

# Security

The use of OpenID Connect is more secure in the long run than relying on AWS credentials stored indefinitely in GitHub Secrets.

In general, I aim to follow the principle of least permissions. However, for the purposes of this project, I just universal permissions in various places in the interest of time. In production, these would need to be tightened up.

