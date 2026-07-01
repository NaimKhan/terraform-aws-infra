locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  azs                     = var.azs
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs

  # prod = ONE NAT Gateway PER AZ. If one AZ has an outage, private
  # subnets in the other AZs still have outbound internet for patching.
  single_nat_gateway = false

  tags = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name    = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  container_port   = var.container_port

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  project_name          = var.project_name
  environment            = var.environment
  image_tag_mutability   = "IMMUTABLE" # prod images can never be overwritten by tag reuse

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment   = var.environment

  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project_name        = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_sg_id             = module.security_groups.alb_sg_id
  container_port        = var.container_port
  certificate_arn       = var.certificate_arn # enables HTTPS + HTTP->HTTPS redirect

  tags = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  project_name         = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ecs_sg_id              = module.security_groups.ecs_sg_id
  target_group_arn       = module.alb.target_group_arn
  ecr_repository_url     = module.ecr.repository_url
  container_port         = var.container_port
  task_cpu                = var.task_cpu
  task_memory              = var.task_memory
  desired_count            = var.desired_count
  execution_role_arn       = module.iam.ecs_task_execution_role_arn
  task_role_arn            = module.iam.ecs_task_role_arn

  enable_autoscaling = true
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cpu_target_value    = 60

  environment_variables = {
    DB_HOST = module.rds.db_endpoint
    APP_ENV = var.environment
  }

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  environment            = var.environment
  private_subnet_ids     = module.vpc.private_subnet_ids
  rds_sg_id              = module.security_groups.rds_sg_id
  db_name                 = var.db_name
  db_username              = var.db_username
  db_password              = var.db_password
  instance_class            = var.db_instance_class
  multi_az                   = true  # standby replica, automatic failover
  backup_retention_period    = 30
  deletion_protection        = true
  skip_final_snapshot        = false # always take a final snapshot in prod

  tags = local.common_tags
}

module "waf" {
  source = "../../modules/waf"

  project_name = var.project_name
  environment    = var.environment
  alb_arn        = module.alb.alb_arn
  rate_limit     = var.waf_rate_limit

  tags = local.common_tags
}

module "route53" {
  source = "../../modules/route53"

  domain_name    = var.domain_name
  create_zone     = false # assumes the zone already exists in Route53
  zone_id         = ""     # set to the real hosted zone ID
  record_name     = "app"  # -> app.example.com
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
}
