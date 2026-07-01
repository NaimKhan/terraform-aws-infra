# CI/CD Pipeline

`terraform-ci.yml` automates plan/apply for all three environments.

## Flow
- **Pull Request → main**: runs `terraform fmt -check`, `terraform validate`,
  and `terraform plan` for dev/qa/prod, then posts the plan output as a PR
  comment so reviewers see the exact infrastructure diff before approving.
  Nothing is ever applied on a PR.
- **Merge → main**: runs `terraform apply` sequentially — dev first, then
  qa, then prod (`max-parallel: 1`).

## Required setup
1. **AWS OIDC role** — create an IAM role trusted by GitHub's OIDC provider
   (no long-lived AWS access keys stored as secrets). Store its ARN as the
   repo secret `AWS_TERRAFORM_ROLE_ARN`.
2. **`DB_PASSWORD`** repo/environment secret — never stored in `.tfvars`.
3. **GitHub Environments** named `dev`, `qa`, `prod` — configure `qa` and
   `prod` with required reviewers so a human must approve before Terraform
   applies against them. `dev` can auto-apply without approval.

## Why this design
- **Plan-on-PR, apply-on-merge** is the standard safe pattern: nobody
  applies from their laptop, every change is reviewed as a diff first.
- **OIDC over static keys** removes long-lived AWS credentials from GitHub
  entirely — short-lived, per-run tokens instead.
- **Manual approval gates on qa/prod** stop an automatic merge from
  silently changing production infrastructure.
