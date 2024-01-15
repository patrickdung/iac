# --- compute_web/variables.tf ---

variable "instance_type" {}
variable "instance_count" {}
variable "security_group_internet_to_web" {}
variable "security_group_internet_to_elb_public_web" {}
variable "subnet_public_web" {}
variable "vol_size" {}
variable "public_key_path" {}
variable "key_name" {}

variable "ssm_cloudwatch_config" {}
variable "connect_to_db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "db_endpoint" {}
variable "user_data_path" {}

variable "iam_instance_profile" {}
