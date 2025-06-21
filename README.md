# Simple Log Service

This project provides a basic log service using AWS Lambda, DynamoDB, and Terraform.

## Functions

- **save_log**: Accepts log entries via API and stores them.
- **get_logs**: Retrieves the 100 most recent log entries.

## Deployment

1. Clone the repo.
2. Set up AWS credentials (use IAM roles or OIDC for GitHub Actions).
3. Run `terraform init` and `terraform apply` in the `terraform` directory.
4. Deploy Lambda functions and connect API Gateway.

## Security

- Data is encrypted using DynamoDB encryption.
- Follows least privilege principles.
- CI/CD pipeline uses secure authentication and runs security checks.
