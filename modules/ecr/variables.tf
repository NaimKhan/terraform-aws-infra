variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE. IMMUTABLE is safer for prod (tags can't be overwritten)."
  type        = string
  default     = "IMMUTABLE"
}

variable "max_image_count" {
  description = "Max number of images to retain before old ones are auto-expired"
  type        = number
  default     = 15
}

variable "tags" {
  type    = map(string)
  default = {}
}
