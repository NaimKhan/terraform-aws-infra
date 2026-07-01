variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the DB subnet group — DB is never in a public subnet"
  type        = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "16.3"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling"
  type        = number
  default     = 100
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  description = "DB master password. In real usage, pull this from a secret store / TF_VAR env var, never commit it."
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "true = standby replica in a second AZ, automatic failover (used in prod)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  description = "Set false for prod so a final snapshot is always taken on destroy"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
