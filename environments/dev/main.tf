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

  # dev = single shared NAT Gateway (cheaper, HA not required)
  single_nat_gateway = true

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

  project_name = var.project_name
  environment   = var.environment

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
  # no certificate_arn -> HTTP only in dev

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
  enable_autoscaling       = false # fixed count in dev

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
  multi_az                   = false # single AZ in dev
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = local.common_tags
}

# No WAF module and no Route53 module called in dev — not needed for a
# throwaway/testing environment. Access the ALB DNS name directly.
