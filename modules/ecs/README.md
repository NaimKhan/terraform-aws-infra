# ECS Module (Fargate)

Runs the application as an ECS Fargate service in private subnets, registered
behind the ALB target group. No EC2 instances to patch — Fargate is serverless.

## What this module creates
- ECS Cluster (Container Insights enabled)
- CloudWatch Log Group
- Task Definition (Fargate, `awsvpc` network mode)
- ECS Service (private subnets, `assign_public_ip = false`)
- Optional Application Auto Scaling (target tracking on CPU) — enabled for qa/prod

## Why Fargate over EC2-backed ECS
No host OS to patch or manage — AWS handles the underlying infrastructure.
Removes an entire class of "did we patch the ECS instances" operational work.

## Inputs (key ones)
| Name | Type | Description |
|---|---|---|
| private_subnet_ids | list(string) | Tasks run here, no public IP |
| ecr_repository_url | string | Image source |
| task_cpu / task_memory | string | Fargate sizing |
| desired_count | number | Fixed count (dev) or autoscaling baseline (qa/prod) |
| enable_autoscaling | bool | true for qa/prod |

## Outputs
| Name | Description |
|---|---|
| cluster_name | ECS cluster name |
| service_name | ECS service name |
