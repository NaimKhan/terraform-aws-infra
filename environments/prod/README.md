# Prod Environment

Full high-availability, secured, production-grade stack.

## What's different from dev/qa
| Feature | dev/qa | prod |
|---|---|---|
| NAT Gateway | 1 shared | 1 per AZ (HA) |
| AZ count | 2 | 3 |
| ECS sizing | 256-512 CPU | 1024+ CPU, autoscale 3-10 |
| RDS | single-AZ, t3.micro/small | Multi-AZ, r6g.large, 30-day backups |
| ALB | HTTP only | HTTPS via ACM cert, HTTP->HTTPS redirect |
| WAF | none | AWS Managed Rules + rate limiting |
| Route53 | none (raw ALB DNS) | custom domain via alias record |
| deletion_protection | false | true (RDS + ALB) |
| ECR image tags | mutable | immutable |

## Prerequisites before running
1. `environments/bootstrap` has already been applied (remote state exists)
2. An ACM certificate has been issued/validated for `certificate_arn`
3. The Route53 hosted zone for `domain_name` already exists (or set `create_zone = true`)

## Usage
```bash
cd environments/prod
terraform init
terraform plan  -var="db_password=$TF_VAR_db_password"
terraform apply -var="db_password=$TF_VAR_db_password"
```

Never commit `db_password`, `certificate_arn`, or account-specific values
into version control as real secrets — this repo uses placeholder values
that must be overridden per real AWS account.
