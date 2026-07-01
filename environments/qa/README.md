# QA Environment

Mid-size environment used for integration testing and pre-prod validation.
Bigger than dev, but still cost-optimized compared to prod.

## What's different from dev
- `desired_count = 2` with autoscaling enabled — tests multi-task behaviour
- Bigger Fargate size (512 CPU / 1024 MB) and `db.t3.small`

## What's different from prod
- Still a single shared NAT Gateway (not NAT-per-AZ)
- RDS is single-AZ, no deletion protection
- No WAF, no custom Route53 domain

## Usage
```bash
cd environments/qa
terraform init
terraform plan  -var="db_password=$TF_VAR_db_password"
terraform apply -var="db_password=$TF_VAR_db_password"
```
