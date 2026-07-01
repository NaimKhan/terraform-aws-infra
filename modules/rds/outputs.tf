output "db_endpoint" {
  description = "DB connection endpoint (only reachable from inside the VPC)"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.this.id
}
