# --- vpc/variables.tf ---

variable "aws_region_shortform" {}
variable "vpc_number" {}
variable "vpc_cidr" {}
variable "public_web_cidrs" {}
variable "private_app_cidrs" {}
variable "private_db_cidrs" {}
variable "public_bastion_cidrs" {}
variable "environment" {}

variable "create_natgw_for_private_subnets" {
  type = bool
  default = false
}

variable "security_group_internet_to_web" {}
variable "security_group_internet_to_elb_public_web" {}
variable "allow_incoming_ssh_ip" {}

variable "security_group_db" {}
variable "security_group_web_to_db" {}
variable "security_group_app_to_db" {}

variable "db_subnetgroup" {}
