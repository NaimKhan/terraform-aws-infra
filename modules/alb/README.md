# ALB Module

Public-facing Application Load Balancer that terminates internet traffic
and forwards it to ECS tasks running in private subnets.

## What this module creates
- Application Load Balancer (in public subnets)
- Target Group (`target_type = ip`, for ECS Fargate)
- HTTP listener (forwards, or redirects to HTTPS if a certificate is supplied)
- HTTPS listener (only created when `certificate_arn` is provided — used in prod)

## Inputs
| Name | Type | Description |
|---|---|---|
| vpc_id | string | VPC ID |
| public_subnet_ids | list(string) | Subnets to place the ALB in |
| alb_sg_id | string | Security group allowing 80/443 |
| container_port | number | Backend app port |
| certificate_arn | string | ACM cert ARN; empty = HTTP only |

## Outputs
| Name | Description |
|---|---|
| alb_dns_name | DNS name to point Route53 at |
| alb_zone_id | Needed for Route53 alias records |
| target_group_arn | Passed into the ECS module |
