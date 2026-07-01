# Dev Environment

Smallest, cheapest environment. Used for day-to-day development and testing.

## What's different from prod
- Single shared NAT Gateway (`single_nat_gateway = true`) — not HA, but cheap
- Smallest Fargate size (256 CPU / 512 MB), `desired_count = 1`, no autoscaling
- `db.t3.micro`, single-AZ RDS, no deletion protection
- No WAF (module not called)
- No Route53 custom domain (module not called) — use the raw ALB DNS name
- HTTP only on the ALB (no ACM certificate configured)

## Usage
```bash
cd environments/dev
terraform init
terraform plan  -var="db_password=$TF_VAR_db_password"
terraform apply -var="db_password=$TF_VAR_db_password"
```

Never commit `db_password` into `terraform.tfvars`. Pass it via
`TF_VAR_db_password` environment variable or a secrets manager / CI/CD secret.
