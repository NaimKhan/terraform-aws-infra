# Security Groups Module

Implements a layered security model: internet -> ALB -> ECS -> RDS.
Each layer only trusts the layer directly in front of it, never the internet directly.

## What this module creates
- `alb-sg` — allows 80/443 from `0.0.0.0/0` (the only public-facing SG)
- `ecs-sg` — allows the container port ONLY from `alb-sg`
- `rds-sg` — allows the DB port ONLY from `ecs-sg`

## Inputs
| Name | Type | Description |
|---|---|---|
| project_name | string | Prefix used in resource names |
| environment | string | dev / qa / prod |
| vpc_id | string | VPC to create the SGs in |
| container_port | number | App container port (default 8080) |
| db_port | number | Database port (default 5432) |

## Outputs
| Name | Description |
|---|---|
| alb_sg_id | ALB security group ID |
| ecs_sg_id | ECS security group ID |
| rds_sg_id | RDS security group ID |
