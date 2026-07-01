# VPC Module

Creates a standard 3-tier VPC network layout used by every environment.

## What this module creates
- 1 VPC
- 1 Internet Gateway
- Public subnets (one per AZ) — hosts ALB and NAT Gateway(s)
- Private subnets (one per AZ) — hosts ECS tasks and RDS (no public IP, no direct internet access)
- NAT Gateway(s) + Elastic IP(s) — gives private subnets outbound-only internet access
  (needed for OS/package patching, pulling container images, calling AWS APIs)
- Route tables + associations for both tiers

## NAT strategy
`single_nat_gateway = true` → one shared NAT Gateway (cost-optimized, used in dev/qa).
`single_nat_gateway = false` → one NAT Gateway per AZ (highly available, used in prod).

## Inputs
| Name | Type | Description |
|---|---|---|
| project_name | string | Prefix used in resource names |
| environment | string | dev / qa / prod |
| vpc_cidr | string | CIDR block for the VPC |
| azs | list(string) | Availability Zones to use |
| public_subnet_cidrs | list(string) | CIDR per public subnet |
| private_subnet_cidrs | list(string) | CIDR per private subnet |
| single_nat_gateway | bool | true = 1 NAT, false = 1 NAT per AZ |

## Outputs
| Name | Description |
|---|---|
| vpc_id | VPC ID |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| nat_gateway_ids | NAT Gateway IDs |
| nat_public_ips | NAT Gateway Elastic IPs |

## Example usage
```hcl
module "vpc" {
  source                = "../../modules/vpc"
  project_name          = "myapp"
  environment            = "prod"
  vpc_cidr               = "10.2.0.0/16"
  azs                     = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnet_cidrs    = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs   = ["10.2.11.0/24", "10.2.12.0/24"]
  single_nat_gateway     = false
}
```
