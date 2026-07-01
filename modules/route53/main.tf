resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
  fqdn    = var.record_name == "" ? var.domain_name : "${var.record_name}.${var.domain_name}"
}

# Alias record -> points straight at the ALB, no extra DNS lookup hop,
# and it's free (unlike a CNAME which still incurs a lookup).
resource "aws_route53_record" "alb_alias" {
  zone_id = local.zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
