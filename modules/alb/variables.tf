variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to place the ALB in"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "container_port" {
  description = "Port the ECS application container listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path used by the ALB target group health check"
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Leave empty to run HTTP only (dev/qa)."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
