# Automated CI/CD pipeline for deploying password-protected static websites with AWS Cloudfront

# High-Level Approach

My basic idea is to fully automate the whole process of deploying and redeploying a static website with GitHub Actions from scratch, including bootstrapping of an S3 bucket for the terraform backend.

I configured OpenID Connect to allow GHA to assume a temporary IAM role and interact with AWS resources.
On the first run, AWS credentials must be stored as secrets GitHub Secrets in order for the terraform backend to be deployed and provisioned. However, in subsequent runs, these credentials are no longer needed thanks to the OIDC setup.

Whenever a change is pushed to the github repo, the GitHub Actions workflow is triggered, which causes any new content in the web/ directory to be synced to an S3 bucket where the website is hosted.

Cloudfront is used together with the website-hosting S3 bucket to provide a lambda edge function which implements user authentication using Basic Auth.

# A Low-cost Solution

-  The Cloudfront Lambda Edge function leverages edge caching and serverless functions
-  GHA workflows are free for up to 2,000 minutes per month (current as of March 2025)
-  Teardown measures throughout the workflow prevent orphaned AWS resources from generating hidden costs

# Instructions

1. Clone this repository to your local IDE
2. Add any static web content of your choosing to the web/ directory
3. Create a GitHub repo and set it as the remote for this repository.
4. Set GitHub Secrets values for the inital run, including:
  - AWS_ACCOUNT_ID
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_SESSION_TOKEN (if using temporary credentials)
  - S3_BUCKET (choose any value you like)
  - WEBSITE_USERNAME
  - WEBSITE_PASSWORD
5. Push your repo to GitHub
6. Find your cloudfront URL in the GitHub Actions output, under "protected URL output"
7. The Lambda@Edge function prompts for credentials on the first request, which browsers typically cache in the Authorization header for the session, avoiding repeated logins.
8. After the first run, delete all secrets from GitHub Secrets for security. All subsequent runs will automatically handle authentication between GitHub Actions and AWS using OIDC

# Maintainability

I made every effort to parameterize credentials and other variable values for maintainability.

Nonetheless, developers should be aware of some changes that might need to be implemented in the future:

1. It might be necessary to update github's thumbprint-list for the OIDC setup in the github_actions_integration module if GitHub’s certificate changes (rare).
 
2. Care should be taken to remove long-lived aws credentials from github secrets after bootstrapping.

3. It might be necessary to update the template file relative path in modules/cloudfront/main.tf in different environments. I made a local version of lambda.zip for use in local development. In the GHA workflow, the index.js.tftlp file is zipped dynamically.

# Security

I implemented OpenID Connect, which is more secure in the long run than relying on AWS credentials stored indefinitely in GitHub Secrets.

In general, I aim to follow the principle of least permissions. However, for the purposes of this project, I just universal permissions in various places in the interest of time. In production, these would need to be tightened up.

# Tradeoffs

## Single-File vs. Modular Workflows:

Decision: Transitioned from a single apply.yml to modular workflows (setup.yml, bootstrap.yml, terraform-prep.yml, etc.).

Tradeoff:
Pro: Improved maintainability, reusability across projects, and logical separation of concerns (e.g., bootstrap vs. deploy). Improved potential for scaling.
Con: Introduced overhead (~2-3 min) from repeated checkout, setup-tools, and terraform init due to job isolation. Some of this was mitigated by caching terraform plugins installation.

## Terraform Initialization Overhead:

Decision: Initially ran terraform init in multiple jobs; later optimized with actions/cache for .terraform/.

Tradeoff:
Pro: Caching reduced init time (~10-20s per job) by reusing plugins.
Con: Still required init per job for S3 backend sync, and caching added minor complexity without fully eliminating repetition.

## Bootstrap Execution Control:

Decision: Added check-bootstrap to skip bootstrap if the state bucket exists, first with job-level if, then step-level conditions.

Tradeoff:
Pro (Job Skip): Avoided unnecessary checkout/setup-tools (~15-20s) when skipping.
Con (Job Skip): Skipped downstream jobs due to needs, breaking the pipeline.
Pro (Step Skip): Ensured downstream jobs always run, waiting for bootstrap when needed.
Con (Step Skip): Minor overhead (~15-20s) from checkout/setup-tools even when skipping Terraform steps.


## Dependency Management:

Decision: Kept bootstrap in terraform-prep’s needs list, ensuring it waits when bootstrap runs, but completes regardless.

Tradeoff:
Pro: Guaranteed state bucket availability for downstream terraform init, preserving original flow.
Con: Slightly less flexible than fully decoupling; downstream jobs still wait for bootstrap’s minimal run time when skipped.

## Efficiency vs. Modularity:

Decision: Chose modularity over a single-job approach.
Tradeoff:
Pro: Enabled potential reuse (e.g., terraform-prep in other projects), easier debugging per job.
Con: Accepted ~2-3 min overhead vs. a single job (~1-2 min total), prioritizing flexibility over runtime.
