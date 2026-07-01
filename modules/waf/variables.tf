variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_arn" {
  description = "ALB ARN to associate the Web ACL with"
  type        = string
}

variable "rate_limit" {
  description = "Max requests per 5-minute window from a single IP before it's blocked"
  type        = number
  default     = 2000
}

variable "tags" {
  type    = map(string)
  default = {}
}
