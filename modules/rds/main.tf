locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# RDS instance — publicly_accessible = false is what makes this DB
# unreachable from the internet, no matter what. It only accepts
# connections from the ECS security group (see security-groups module),
# and it lives in private subnets with no route to the Internet Gateway.
# It reaches AWS backup/patch endpoints via the AWS-managed RDS control
# plane, not through the VPC's NAT Gateway — RDS patching is handled by
# AWS during the defined maintenance window, not by outbound internet access.
# ---------------------------------------------------------------------------
resource "aws_db_instance" "this" {
  identifier     = "${var.project_name}-${var.environment}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false # never directly reachable from the internet

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot"

  auto_minor_version_upgrade = true # AWS applies minor engine patches automatically

  tags = local.common_tags
}
