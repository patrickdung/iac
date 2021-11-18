# --- modules/rds_postgres/variables.tf ----

#variable "create_rds_postgres" {}
variable "db_instance_class" {}
#variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "skip_db_snapshot" {}
variable "vpc_security_group_ids" {}
variable "db_subnet_group_name" {}
variable "db_engine_version" {}
variable "db_identifier" {}

variable "db_instance_number" {}

variable "environment" {}
variable "generic_vpc_tag_name" {}
