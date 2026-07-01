aws_region  = "ap-southeast-1"
project_name = "myapp"
environment  = "prod"

# 3 AZs in prod for stronger HA than dev/qa's 2
vpc_cidr              = "10.2.0.0/16"
azs                    = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
public_subnet_cidrs    = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnet_cidrs   = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

container_port = 8080
task_cpu        = "1024"
task_memory     = "2048"
desired_count   = 3
min_capacity    = 3
max_capacity    = 10

db_name           = "myappdb"
db_username       = "myapp_admin"
db_instance_class = "db.r6g.large"

domain_name      = "example.com"          # CHANGE to the real domain
certificate_arn  = "arn:aws:acm:ap-southeast-1:123456789012:certificate/CHANGE-ME"

waf_rate_limit = 2000

# db_password: pass via TF_VAR_db_password / CI secret manager, never commit
