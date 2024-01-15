# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration

data "aws_ami" "ami_asg_public_compute_web" {

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
    # AMZ Linux 2023, not minimal
    values = ["al2023-ami-2023*"]
    # AMZ Linux 2022 (preview), not minimal
    #values = ["al2022-ami-2022*"]
    # minimal
    #values = ["al2022-ami-minimal-2022*"]
  }

}

#resource "aws_launch_configuration" "launch_config_public_compute_web" {
resource "aws_launch_template" "launch_template_public_compute_web" {

  lifecycle {
    create_before_destroy = true

  ## So that it won't re-create the instance when the AMI updates
  ##  ignore_changes = [ami]
  }

  ###name = "launch_config_public_compute_web"
  ###name = "launch_template_public_compute_web"
  name_prefix = "public_compute_web-"
  # AMZ Linux 2022 (preview) x86_64
  #image_id = "ami-0d59252a0322103a5"
  image_id = data.aws_ami.ami_asg_public_compute_web.id
  instance_type = var.instance_type
  #key_name = "asg-public-compute-web-${aws_key_pair.compute_web_ssh_public_key.id}"
  key_name = "${aws_key_pair.compute_web_ssh_public_key.id}"


  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.security_group_internet_to_web
    ##subnet_id = var.subnet_public_web
    ##subnet_id = module.vpc.subnet_public_web
  }

      #nodename    = "ec2-${random_id.compute_web_node_id[count.index].dec}"
  #user_data = templatefile("${var.user_data_path}-al2022",
  user_data = base64encode(templatefile("${var.user_data_path}-al2022",
    {
      ssm_cloudwatch_config = var.ssm_cloudwatch_config
      db_endpoint = var.db_endpoint
      db_user     = var.db_user
      db_pass     = var.db_password
      connect_to_db_name  = var.connect_to_db_name
    }
  ))

  #root_block_device {
  #  volume_size = var.vol_size
  #}

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.vol_size
      volume_type = "gp2"
      #delete_on_termination = "false"
      encrypted = "false"
    }
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  #tags = {
  #  Name = "ec2-${random_id.compute_web_node_id[count.index].dec}"
  #}

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb
resource "aws_elb" "asg_public_web_elb_web01" {

  name = "asg-public-web-elb-web01"

  security_groups = var.security_group_internet_to_elb_public_web

  subnets = var.subnet_public_web
  ##subnets = module.vpc.subnet_public_web

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 4
    interval = 15
    #target = "HTTP:80/"
    target = "HTTP:80/info.html"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }

}

resource "aws_autoscaling_group" "asg_public_web_group01" {

  # Required to re-deploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  name = "asg-public-web-group01-${aws_launch_template.launch_template_public_compute_web.name}"

  #availability_zones = ["ap-northeast-2"]
  vpc_zone_identifier = var.subnet_public_web

  ##desired_capacity   = 2
  min_size           = 2
  max_size           = 4

  #launch_configuration = aws_launch_configuration.launch_configuration_public_compute_web.id

  launch_template {
    id      = aws_launch_template.launch_template_public_compute_web.id
    version = "$Latest"
  }

  health_check_type  = "ELB"
  load_balancers = [
    aws_elb.asg_public_web_elb_web01.id
  ]
  health_check_grace_period=120

}

resource "aws_autoscaling_policy" "asg_policy_public_web_group01" {
  name                   = "asg_policy_public_web_gorup01"
  adjustment_type        = "ChangeInCapacity"
  # scaling_adjustment, cooldown only for simple tracking
  #scaling_adjustment     = 1
  #cooldown               = 300
  #cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg_public_web_group01.name

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}
