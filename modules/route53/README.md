# Route53 Module

Maps a domain/subdomain to the ALB using an alias record.

## What this module creates
- (Optional) a new hosted zone, if `create_zone = true`
- An A/alias record pointing at the ALB DNS name

## Inputs
| Name | Type | Description |
|---|---|---|
| domain_name | string | Root domain, e.g. example.com |
| create_zone | bool | Create new zone vs use existing |
| zone_id | string | Existing zone ID (if not creating) |
| record_name | string | Subdomain, e.g. "app" -> app.example.com |
| alb_dns_name / alb_zone_id | string | From the ALB module outputs |

## Outputs
| Name | Description |
|---|---|
| name_servers | Point your domain registrar at these (only if zone was created here) |
