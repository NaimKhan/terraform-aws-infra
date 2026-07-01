variable "domain_name" {
  description = "Domain name to manage, e.g. example.com"
  type        = string
}

variable "create_zone" {
  description = "true = create a new hosted zone, false = use an existing one via zone_id"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Existing Route53 hosted zone ID (required if create_zone = false)"
  type        = string
  default     = ""
}

variable "record_name" {
  description = "Subdomain to create, e.g. 'app' -> app.example.com. Use '' for the apex/root domain."
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}
