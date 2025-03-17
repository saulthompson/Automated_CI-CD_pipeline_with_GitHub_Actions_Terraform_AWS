# Saul's Cloud-Deployment-Challenge

It might be necessary to update github's thumbprint-list for the OIDC setup in the github_actions_integration module

It was necessary to use AWS credentials in github secrets for initial bootstrapping because
OIDC relies on a pre-existing 
care should be taken to remove long-lived aws credentials from github secrets after bootstrapping

You might need to update the template file relative path in modules/cloudfront/main.tf in different environments
