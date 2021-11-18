variable "aws_region" {
  default = "ap-northeast-2"
}

# --- module vpc ---
variable "aws_region_shortform" {
  default = "apne2"
}

variable "vpc_number" {}
variable "vpc_cidr" {}
variable "environment" {}
variable "create_natgw_for_private_subnets" {}
variable "allow_incoming_ssh_ip" {}
variable "db_subnetgroup" {}

# --- module rds_postgres ---

#variable "create_rds_postgres" {}
#variable "db_name" {
#  type = string
#}

variable "db_instance_number" {}
variable "db_engine_version" {}
variable "db_instance_class" {}

variable "db_user" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}

# --- module compute_web ---

#variable "ssm_cloudwatch_config" {}
variable "connect_to_db_name" {}
