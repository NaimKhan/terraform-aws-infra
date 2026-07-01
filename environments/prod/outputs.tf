output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "app_url" {
  value = "https://${module.route53.record_fqdn}"
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "db_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}
