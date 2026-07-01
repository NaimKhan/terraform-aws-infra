variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID these security groups belong to"
  type        = string
}

variable "container_port" {
  description = "Port the ECS application container listens on"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port the database listens on"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Extra tags to merge into every resource"
  type        = map(string)
  default     = {}
}
