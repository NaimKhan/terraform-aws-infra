variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Private subnets to run ECS tasks in — NO public IP assigned"
  type        = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "target_group_arn" {
  description = "ALB target group ARN this service registers with"
  type        = string
}

variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "environment_variables" {
  description = "Plain (non-secret) environment variables for the container"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Autoscaling — enabled for qa/prod, disabled (fixed count) for dev.
# ---------------------------------------------------------------------------
variable "enable_autoscaling" {
  type    = bool
  default = false
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "cpu_target_value" {
  description = "Target average CPU utilization % for autoscaling"
  type        = number
  default     = 60
}

variable "tags" {
  type    = map(string)
  default = {}
}
