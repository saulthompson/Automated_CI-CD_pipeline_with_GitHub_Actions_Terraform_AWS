# Saul's Cloud-Deployment-Challenge

# Approach

My basic idea is to fully automate the whole process of deploying and redeploying our website with GitHub Actions, including bootstrapping of an S3 bucket for the terraform backend.

I configured OpenID Connect to allow GHA to assume a temporary IAM role and interact with AWS resources.
On the first bootstrapping run, AWS credentials must be stored as GitHub Secrets. However, in subsequent runs, the credentials are no longer needed thanks to the OIDC setup.

Whenever a change is pushed to this github repo, the workflow is triggered, and new content is synced to an S3 bucket where the website is hosted.

Cloudfront is used together with the website-hosting S3 bucket to provide a lambda edge function which implements user authentication using Basic Auth. The reason I used a lambda edge function with cloudfront, besides ease of use, is because of the cost-saving efficacy of cloudfront edge caching and serverless functions. Other cost-saving measures include the fact that GHA workflows are free for up to 2,000 minutes per month, and the teardown measures I implemented in the workflow, which prevent orphaned AWS resources.

# N.B. incomplete status of project

My approach relies on creating a cloudfront distribution. Unfortunately, my AWS account remains unverified, despite my attempts over the past days to complete the verification process. As a result, I am not authorized to create cloudfront distributions in my account, and have been unable to complete end-to-end testing. 

I considered an alternative solution, in which I would host the website in an S3 bucket without cloudfront, and implement credential authentication by adding a js file with an authentication flow interacting directly with the DOM to the web directory. I ultimately decided to leave my current, untested implementation, because it's a better solution overall, and in the interests of time.

# Instructions

Create a GitHub repo and set it as the remote for this repository.

All initial credentials are managed via GitHub Secrets. Make sure to set WEBSITE_PASSWORD and WEBSITE_USERNAME, as well as AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY in GitHub secrets inside your remote repo. 

If you have root access to the AWS account you are using, you can use the credentials.sh script to set the GH secrets, and to create a dedicated IAM user with its own credentials. If you do this, make sure to first set all the relevant credentials as environment variables in the environment where the shell script executes.

If you don't have root access to the AWS account you are using, simply enter your AWS credentials as GitHub actions secrets at https://github.com/<username>/<repo-name>/settings/secrets/actions. You will need to, at minimum, enter separate values for each of the following secret keys:

- AWS_ACCOUNT_ID
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET (choose any value you like)

 The value you set for S3_BUCKET will be the name of the S3 bucket that hosts your website.

Make any desired changes to the web directory, commit, and push to the remote. This will automatically trigger the GHA workflow, which will deploy all necessary architecture on AWS. 

Find your cloudfront URL in the GitHub Actions output, under "protected URL output". When you navigate to this URL in a web browser, you will be prompted for credentials. Once you enter credentials, a hash of the credentials is set as the Authorization header value for all future requests to this URL within the same browser session, allowing you to navigate to the URL in different tabs or windows without having to re-enter credentials.

# Maintainability

I made every effort to parameterize credentials and other variable values for maintainability.

Nonetheless, developers should be aware of some changes that might need to be implemented in the future:

1. It might be necessary to update github's thumbprint-list for the OIDC setup in the github_actions_integration module.
 
2. Care should be taken to remove long-lived aws credentials from github secrets after bootstrapping.

3. It might be necessary to update the template file relative path in modules/cloudfront/main.tf in different environments. I made a local version of lambda.zip for use in local development. In the GHA workflow, the index.js.tlp file is zipped dynamically.

4. currently, website credentials are hardcoded in modules/cloudfront/lambda/index.js.tpl . My intention was to inject credentials dynamically as TF_VARs using Terraform's tpl templating capabilities. This remains the long-term aim, but in the interests of time and testing all the other components, I have left them hardcoded for now.

# Security

The use of OpenID Connect is more secure in the long run than relying on AWS credentials stored indefinitely in GitHub Secrets.

In general, I aim to follow the principle of least permissions. However, for the purposes of this project, I just universal permissions in various places in the interest of time. In production, these would need to be tightened up.

