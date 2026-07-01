aws_region  = "ap-southeast-1"
project_name = "myapp"
environment  = "qa"

vpc_cidr              = "10.1.0.0/16"
azs                    = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnet_cidrs    = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs   = ["10.1.11.0/24", "10.1.12.0/24"]

container_port = 8080
task_cpu        = "512"
task_memory     = "1024"
desired_count   = 2   # baseline HA for testing multi-task behaviour
min_capacity    = 2
max_capacity    = 4

db_name           = "myappdb"
db_username       = "myapp_admin"
db_instance_class = "db.t3.small"

# db_password: pass via TF_VAR_db_password, do not commit
