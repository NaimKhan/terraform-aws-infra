# Terraform AWS Production Infrastructure

A modular, reusable Terraform project for deploying a 3-tier containerized
application on AWS across three isolated environments: **dev**, **qa**, and
**prod**.

Built to demonstrate production-grade Terraform practices: reusable modules,
remote state with locking, environment isolation, layered security groups,
and environment-specific sizing/HA.

## Architecture

```
                                   Internet
                                       │
                          ┌────────────▼────────────┐
                          │      Route53 (prod)      │
                          └────────────┬────────────┘
                                       │
                          ┌────────────▼────────────┐
                          │     WAF (prod only)      │
                          └────────────┬────────────┘
                                       │
        ┌──────────────────────────────────────────────────────┐
        │                        VPC                             │
        │   ┌─────────────── Public Subnets ────────────────┐   │
        │   │                                                 │   │
        │   │   [ALB] ── HTTPS/HTTP (80/443, 0.0.0.0/0)      │   │
        │   │   [NAT Gateway(s)]                             │   │
        │   │                                                 │   │
        │   └────────────────────┬────────────────────────────┘   │
        │                        │ forwards app traffic            │
        │   ┌──────────────── Private Subnets ─────────────────┐  │
        │   │                                                   │  │
        │   │   [ECS Fargate Service]  <- pulls image from ECR  │  │
        │   │        │ no public IP, no direct internet inbound │  │
        │   │        │ outbound via NAT (patch/pull/API calls)  │  │
        │   │        ▼                                           │  │
        │   │   [RDS Database] <- only reachable from ECS SG    │  │
        │   │        no public IP, never internet-facing        │  │
        │   │                                                   │  │
        │   └───────────────────────────────────────────────────┘  │
        └────────────────────────────────────────────────────────┘
```

**Security model:** internet → ALB → ECS → RDS. Each layer only trusts the
layer directly in front of it. The database and application containers are
never directly reachable from the internet — only the ALB is public. Private
resources get outbound-only internet access through the NAT Gateway, which
is what allows OS package patching, pulling container images, and calling
AWS APIs without ever accepting inbound connections from the internet.

## Repository structure

```
terraform-aws-infra/
│
├── modules/                     # Reusable, environment-agnostic building blocks
│   ├── vpc/                     # VPC, public/private subnets, IGW, NAT Gateway(s), routing
│   ├── security-groups/         # Layered SGs: alb-sg -> ecs-sg -> rds-sg
│   ├── alb/                     # Application Load Balancer, target group, listeners
│   ├── ecr/                     # Container image registry
│   ├── iam/                     # ECS task execution role + task role (least privilege)
│   ├── ecs/                     # ECS Fargate cluster, service, task definition, autoscaling
│   ├── rds/                     # Private database, encrypted, no public access
│   ├── route53/                 # DNS record pointing the domain at the ALB
│   └── waf/                     # AWS WAFv2 attached to the ALB
│
├── environments/                 # Environment-specific root configurations
│   ├── bootstrap/                # One-time setup: S3 + DynamoDB for remote state
│   ├── dev/                      # Smallest, cheapest, no HA
│   ├── qa/                       # Mid-size, tests autoscaling, still cost-optimized
│   └── prod/                     # Full HA: NAT per AZ, Multi-AZ RDS, WAF, Route53, HTTPS
│
└── .gitignore
```

### Why this structure

- **`modules/`** contains no hardcoded environment values — everything comes
  in through `variables.tf`. This is what makes a module *reusable*: the same
  VPC module is called by dev, qa, and prod with different inputs.
- **`environments/<env>/`** is a **root module** — the actual entry point
  where `terraform init/plan/apply` is run. It wires the reusable modules
  together for that specific environment and supplies real values via
  `terraform.tfvars`.
- Keeping dev/qa/prod as **fully separate root configs with separate state
  files** (rather than one shared config with a `count`/`workspace` switch)
  gives clean blast-radius isolation: a mistake in dev cannot touch prod
  state, and IAM permissions to run `terraform apply` can be scoped
  per-environment.

## Remote state

State is stored in S3 (versioned + encrypted) with DynamoDB used for state
locking, so two people (or a person and a CI/CD pipeline) can never apply
against the same environment at the same time. Each environment uses its own
state file key (`dev/terraform.tfstate`, `qa/terraform.tfstate`,
`prod/terraform.tfstate`) inside the same bucket.

The S3 bucket and DynamoDB table themselves are created by
`environments/bootstrap`, using a local backend (since nothing can create the
remote backend using the remote backend).

## Getting started

```bash
# 1. One-time: create the S3 bucket + DynamoDB table for remote state
cd environments/bootstrap
terraform init
terraform apply

# 2. Deploy an environment
cd ../dev
terraform init
terraform plan  -var="db_password=$TF_VAR_db_password"
terraform apply -var="db_password=$TF_VAR_db_password"
```

Repeat step 2 for `qa` and `prod` (with their own `terraform.tfvars`).

## Environment comparison

| | dev | qa | prod |
|---|---|---|---|
| AZs | 2 | 2 | 3 |
| NAT Gateway | 1 shared | 1 shared | 1 per AZ (HA) |
| ECS sizing | 256 CPU / 512 MB, count 1 | 512 CPU / 1024 MB, count 2, autoscale | 1024 CPU / 2048 MB, count 3, autoscale 3-10 |
| RDS | db.t3.micro, single-AZ | db.t3.small, single-AZ | db.r6g.large, Multi-AZ |
| ALB | HTTP only | HTTP only | HTTPS (ACM) + redirect |
| WAF | no | no | yes |
| Route53 | no | no | yes |
| Deletion protection | off | off | on |

## Module documentation

Each module has its own `README.md` with inputs/outputs:
[`vpc`](modules/vpc/README.md) ·
[`security-groups`](modules/security-groups/README.md) ·
[`alb`](modules/alb/README.md) ·
[`ecr`](modules/ecr/README.md) ·
[`iam`](modules/iam/README.md) ·
[`ecs`](modules/ecs/README.md) ·
[`rds`](modules/rds/README.md) ·
[`route53`](modules/route53/README.md) ·
[`waf`](modules/waf/README.md)

## Secrets handling

`db_password` and other sensitive values are never committed to
`terraform.tfvars`. They are passed at apply-time via `TF_VAR_*` environment
variables or a CI/CD secrets manager (e.g. GitHub Actions secrets, AWS
Secrets Manager). See each environment's README for details.
