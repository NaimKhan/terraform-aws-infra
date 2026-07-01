output "name_servers" {
  description = "Name servers for the created zone (only set if create_zone = true) — point your domain registrar at these"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "record_fqdn" {
  value = aws_route53_record.alb_alias.fqdn
}
