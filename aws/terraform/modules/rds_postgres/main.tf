# --- modules/rds_postgres ---

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

resource "aws_db_instance" "rds_postgres" {
  #count = var.create_rds_postgres ? 1 : 0
  allocated_storage      = 8
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  #name                   = var.db_name
  username               = var.db_user
  password               = var.db_password
  skip_final_snapshot    = var.skip_db_snapshot
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  identifier             = var.db_identifier
  tags = {
    Name = "rds-${var.generic_vpc_tag_name}-pgsql-${var.db_instance_number}"
    Environment = "${var.environment}"
  }
}
