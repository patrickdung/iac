# --- iam/ec2-to-ssm/main.tf ---

resource "aws_iam_instance_profile" "custom_iam_profile_ec2_to_ssm" {
  name = "profile_ec2_to_ssm"
  role = aws_iam_role.custom_iam_role.name
}

resource "aws_iam_role" "custom_iam_role" {
  name               = "Custom-EC2-to-SSM-role"
  description        = "Custom Role - Enables EC2 instances to access SSM with CW Logs and Agent support."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
  tags = {
    Name = "Custom-EC2-to-SSM-role"
    Creator = "terraform"
  }
}

## https://stackoverflow.com/questions/45486041/how-to-attach-multiple-iam-policies-to-iam-roles-using-terraform
resource "aws_iam_role_policy_attachment" "custom_ssm_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])
  role       = aws_iam_role.custom_iam_role.name
  policy_arn = each.value
}
