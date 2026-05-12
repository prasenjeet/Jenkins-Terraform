# Jenkins + Terraform Sample Project

A reference project demonstrating how to use **Jenkins pipelines** to manage **Terraform** infrastructure-as-code on AWS. It provisions a VPC and EC2 instance in separate `dev` and `prod` environments via reusable modules.

## Project Structure

```
.
├── Jenkinsfile                    # Declarative pipeline definition
├── scripts/                       # Shell helpers invoked by Jenkins
│   ├── tf-init.sh
│   ├── tf-plan.sh
│   ├── tf-apply.sh
│   └── tf-destroy.sh
└── terraform/
    ├── modules/
    │   ├── vpc/                   # Reusable VPC module
    │   └── ec2/                   # Reusable EC2 module
    └── environments/
        ├── dev/                   # Dev environment root config
        └── prod/                  # Prod environment root config
```

## Prerequisites

| Tool        | Version  |
|-------------|----------|
| Jenkins     | 2.440+   |
| Terraform   | 1.7+     |
| AWS CLI     | 2.x      |

### Jenkins Plugins Required
- [Pipeline](https://plugins.jenkins.io/workflow-aggregator/)
- [AWS Credentials](https://plugins.jenkins.io/aws-credentials/)
- [Terraform](https://plugins.jenkins.io/terraform/)
- [AnsiColor](https://plugins.jenkins.io/ansicolor/)

## Jenkins Setup

1. Create an **AWS Credentials** entry (kind: *AWS Credentials*) in Jenkins with ID `aws-credentials`.
2. Create a new Pipeline job pointing to this repository.
3. Set the `ENVIRONMENT` parameter to `dev` or `prod`.
4. Set the `TF_ACTION` parameter to `plan`, `apply`, or `destroy`.

## Pipeline Stages

```
Checkout → Terraform Init → Terraform Validate → Terraform Plan
  → [Approval Gate for apply/destroy] → Terraform Apply / Destroy → Notifications
```

## Running Locally

```bash
# Export AWS credentials
export AWS_ACCESS_KEY_ID=<your-key>
export AWS_SECRET_ACCESS_KEY=<your-secret>
export AWS_DEFAULT_REGION=us-east-1

# Dev environment
cd terraform/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Destroy
terraform destroy -var-file=terraform.tfvars
```

## Remote State (S3 Backend)

Each environment uses an S3 backend.  Create the bucket and DynamoDB lock table before first use:

```bash
aws s3api create-bucket --bucket my-tf-state-bucket --region us-east-1
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Then update `backend_bucket` and `dynamodb_table` in each environment's `terraform.tfvars`.
