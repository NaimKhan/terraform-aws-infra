aws_region  = "ap-southeast-1"
project_name = "myapp"
environment  = "dev"

vpc_cidr              = "10.0.0.0/16"
azs                    = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]

container_port = 8080
task_cpu        = "256"   # smallest Fargate size
task_memory     = "512"
desired_count   = 1        # no HA needed in dev

db_name           = "myappdb"
db_username       = "myapp_admin"
db_instance_class = "db.t3.micro"

# db_password should NOT live in this file in a real repo.
# Pass it via: terraform apply -var="db_password=xxxx"
# or better, via TF_VAR_db_password environment variable / a secrets manager.
