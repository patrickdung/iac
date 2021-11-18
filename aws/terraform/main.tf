# --- root/main.tf ---

terraform {
  required_version = ">= 1.00"
}

module "iam_ec2_to_ssm" {
  source = "./modules/iam/ec2_to_ssm"
}

module "ssm_cloudwatch_agent_web" {
  source = "./modules/ssm/cloudwatch_agent_web"
}

# Deploy VPC
module "vpc" {
  source               = "./modules/vpc"
  aws_region_shortform = var.aws_region_shortform
  vpc_number           = var.vpc_number
  vpc_cidr             = var.vpc_cidr

  # https://www.terraform.io/docs/language/functions/range.html
  # start, limit, step
  public_web_cidrs  = [for i in range(0, 3, 1) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_app_cidrs = [for i in range(3, 6, 1) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_db_cidrs  = [for i in range(6, 9, 1) : cidrsubnet(var.vpc_cidr, 8, i)]

  # /28
  public_bastion_cidrs = [for i in range(0, 3, 1) :
    cidrsubnet(cidrsubnet(var.vpc_cidr, 8, 9), 4, i)
  ]

  create_natgw_for_private_subnets = var.create_natgw_for_private_subnets

  security_group_internet_to_web = local.security_group_internet_to_web
  allow_incoming_ssh_ip           = var.allow_incoming_ssh_ip

  security_group_db = local.security_group_db
  security_group_web_to_db = local.security_group_web_to_db
  security_group_app_to_db = local.security_group_app_to_db

  db_subnetgroup = var.db_subnetgroup

  environment = var.environment
}

module "rds_postgres" {
  source                 = "./modules/rds_postgres"
  #create_rds_postgres    = var.create_rds_postgres
  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  db_instance_number     = var.db_instance_number
  ## db_name                 = "rds_postgres"
  db_user                = var.db_user
  db_password            = var.db_password
  db_identifier          = "rds-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-pgsql-${var.db_instance_number}"
  skip_db_snapshot       = true
  db_subnet_group_name   = module.vpc.db_subnetgroup_name[0]
  # using the output of the module
  ##vpc_security_group_ids = module.vpc.security_group_db
  ##vpc_security_group_ids = concat(module.vpc.security_group_web_to_db,module.vpc.security_group_app_to_db)
  vpc_security_group_ids = concat(module.vpc.security_group_db,module.vpc.security_group_web_to_db,module.vpc.security_group_app_to_db)

  environment = var.environment
  generic_vpc_tag_name = "${local.generic_vpc_tag_name}"
}

module "compute_web" {
  source              = "./modules/compute_web"
  security_group_internet_to_web   = module.vpc.security_group_internet_to_web
  subnet_public_web   = module.vpc.subnet_public_web
  instance_count      = 1
  instance_type       = "t3.micro"
  ## │ Error: Error launching source instance: InvalidBlockDeviceMapping: Volume of size 8GB is smaller than  snapshot 'snap-0aa089b1b6c22f9ad', expect size >= 30GB
  vol_size            = "30"
  public_key_path     = "${path.root}/../secrets/main.publickey"
  key_name            = "main"
  
  #ssm_cloudwatch_config = var.ssm_cloudwatch_config 
  ssm_cloudwatch_config = module.ssm_cloudwatch_agent_web.ssm_cw_agent_web_name
  db_endpoint         = module.rds_postgres.database_endpoint
  connect_to_db_name   = var.connect_to_db_name
  db_user              = var.db_user
  db_password          = var.db_password
  user_data_path      = "${path.root}/modules/compute_web/userdata.tpl"
  iam_instance_profile = module.iam_ec2_to_ssm.custom_iam_profile_ec2_to_ssm
}
