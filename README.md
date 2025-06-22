# Simple Log Service

This project provides a basic log service built with AWS Lambda, DynamoDB, API Gateway, and Terraform.

---

## How to Deploy

### Terraform

* Terraform is used to deploy the service to AWS.

### GitHub Actions

#### 1. Deploy Log Service (Triggered by push to `main`)

* On push pipeline creates an S3 bucket that will be use for state lock.

* GitHub Actions pipeline will then deploy the infrastructure.

* The pipeline also runs **tfsec** and **Checkov** for security checks.

  *Note: the pipeline will not fail even if critical vulnerabilities are found.*

#### 2. Destroy Log Service (Triggered Manually)

* This action destroys the infrastructure in the environment.
* It does not delete the S3 bucket or DynamoDB table used for state locking.

---

### Adding AWS Credentials to GitHub

To allow GitHub Actions to deploy to AWS, you need to add AWS credentials as secrets:

1. Go to your AWS account and create an IAM User with programmatic access.
2. Assign the user the necessary permissions.
3. In AWS IAM console, note the **AWS\_ACCESS\_KEY\_ID** and **AWS\_SECRET\_ACCESS\_KEY**.
4. In GitHub:

   * Go to your repo.
   * Click on **Settings** → **Secrets and variables** → **Actions** → **Secrets**.
   * Add the following secrets:

     * `AWS_ACCESS_KEY_ID`
     * `AWS_SECRET_ACCESS_KEY`

GitHub Actions will use these credentials to authenticate and deploy the resources.

---

## Functions

### `save_log`

* Accepts log entries via API and stores them in DynamoDB.
* Uses API key for authentication.
* Log `ID` and `DateTime` are generated automatically.

**To add logs using AWS Console (POST method - request body):**

```json
{
  "severity": "info",
  "message": "Test log entry from API Gateway console"
}
```

**To add logs using PowerShell:**

```powershell
Invoke-WebRequest `
  -Uri "https://<your-api-gateway-id>.execute-api.eu-west-1.amazonaws.com/prod/log" `
  -Headers @{ 
    "x-api-key"    = "<your-api-key>"
    "Content-Type" = "application/json"
  } `
  -Method POST `
  -Body '{"severity": "info", "message": "Test log entry from PowerShell"}'
```

---

### `get_logs`

* Retrieves the 100 most recent log entries.

**To get logs using AWS Console (GET method):**

* No request body or parameters needed.

**To get logs using PowerShell:**

```powershell
$response = Invoke-WebRequest `
  -Uri "https://<your-api-gateway-id>.execute-api.eu-west-1.amazonaws.com/prod/log" `
  -Headers @{ "x-api-key" = "<your-api-key>" } `
  -Method GET

$logs = $response.Content | ConvertFrom-Json

$logs | ConvertTo-Json -Depth 10
```

---

## Security

* DynamoDB encryption at rest is enabled.
* Least privilege IAM policies are used.
* GitHub Actions pipeline uses secure authentication.
* Security checks (tfsec, Checkov) run in CI/CD pipeline.
* API access is secured with API key authentication.

---


