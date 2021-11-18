# --- rds_postgres/outputs.tf ---

output "database_endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}