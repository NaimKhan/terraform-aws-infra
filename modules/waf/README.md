# WAF Module

Attaches AWS WAFv2 to the ALB for layer-7 protection. Used in prod
(and optionally qa); usually skipped in dev to save cost.

## What this module creates
- WAFv2 Web ACL (REGIONAL scope, for ALB) with:
  - AWS Managed Common Rule Set (blocks common exploits, SQLi patterns, etc)
  - AWS Managed Known Bad Inputs rule set
  - A rate-based rule blocking any single IP exceeding the configured request rate
- Association of the Web ACL to the ALB

## Inputs
| Name | Type | Description |
|---|---|---|
| alb_arn | string | ALB to protect |
| rate_limit | number | Max requests/5min from one IP before block |

## Outputs
| Name | Description |
|---|---|
| web_acl_arn | Web ACL ARN |
