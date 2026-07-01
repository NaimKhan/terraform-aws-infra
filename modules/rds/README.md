# RDS Module

Private, non-public database. Only reachable from ECS tasks over the RDS
security group — never from the internet, never from the ALB directly.

## What this module creates
- DB Subnet Group (private subnets only)
- RDS instance: `publicly_accessible = false`, encrypted storage, automated backups

## Patching note
RDS engine patching is handled by AWS during the maintenance window using
`auto_minor_version_upgrade = true` — it does NOT require outbound internet
access from the DB itself. This is different from EC2/ECS-hosted software,
where the NAT Gateway is what provides outbound internet for OS/package
patching. RDS is a managed service, so AWS patches it via the control plane.

## Environment differences
| | dev/qa | prod |
|---|---|---|
| instance_class | db.t3.micro/small | db.r6g.large+ |
| multi_az | false | true |
| deletion_protection | false | true |
| skip_final_snapshot | true | false |

## Outputs
| Name | Description |
|---|---|
| db_endpoint | Connection string used by ECS task environment variables |
