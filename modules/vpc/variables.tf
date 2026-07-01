# ---------------------------------------------------------------------------
# Core naming / tagging inputs
# ---------------------------------------------------------------------------
variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "tags" {
  description = "Extra tags to merge into every resource"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Network sizing inputs
# ---------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones to spread subnets across"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ). Hosts ALB and NAT Gateway(s)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ). Hosts ECS tasks and RDS."
  type        = list(string)
}

# ---------------------------------------------------------------------------
# NAT strategy
# ---------------------------------------------------------------------------
# single_nat_gateway = true  -> ONE NAT Gateway shared by all private subnets.
#                                Cheaper, but not highly available (used for dev/qa).
# single_nat_gateway = false -> ONE NAT Gateway PER AZ.
#                                Higher cost, but if one AZ goes down, the others
#                                still have outbound internet. Used for prod.
variable "single_nat_gateway" {
  description = "If true, create one shared NAT Gateway. If false, create one NAT Gateway per AZ (HA)."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
