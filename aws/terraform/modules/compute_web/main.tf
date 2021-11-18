# --- compute_web/main.tf ---

data "aws_ami" "server_ami" {
  most_recent = true

  # Only official images from AMZ
  owners = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    # ECS optimized image
    values = ["amzn2-ami-ecs-*"] # ECS optimized image
  }

}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs
resource "random_id" "compute_web_node_id" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    #ami_id = "${var.ami_id}"
    ami_id = data.aws_ami.server_ami.id
  }
  byte_length = 4
  count       = var.instance_count
}

resource "aws_key_pair" "compute_web_ssh_public_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "compute_web_node" {

  # So that it won't re-create the instance when the AMI updates
  lifecycle {
    ignore_changes = [ami]
  }

  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  count         = var.instance_count
  key_name               = aws_key_pair.compute_web_ssh_public_key.id
  ## vpc_security_group_ids = [var.security_group_internet_to_web]
  vpc_security_group_ids = var.security_group_internet_to_web
  subnet_id              = var.subnet_public_web[count.index]

  user_data = templatefile(var.user_data_path,
    {
      nodename    = "ec2-${random_id.compute_web_node_id[count.index].dec}"
      ssm_cloudwatch_config = var.ssm_cloudwatch_config
      db_endpoint = var.db_endpoint
      db_user     = var.db_user
      db_pass     = var.db_password
      connect_to_db_name  = var.connect_to_db_name
    }
  )

  root_block_device {
    volume_size = var.vol_size
  }

  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "ec2-${random_id.compute_web_node_id[count.index].dec}"
  }
}
