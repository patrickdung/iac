# --- vpc/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "db_subnetgroup_name" {
  value = aws_db_subnet_group.db_subnetgroup.*.name
}

output "security_group_db" {
  value = [aws_security_group.security_group_db["database"].id]
}

output "security_group_internet_to_web" {
  value = [aws_security_group.security_group_internet_to_web["public_web"].id]
}

output "security_group_internet_to_elb_public_web" {
  value = [aws_security_group.security_group_internet_to_elb_public_web["elb_public_web"].id]
}

output "security_group_web_to_db" {
  value = [aws_security_group.security_group_web_to_db["web_to_db"].id]
}

output "security_group_app_to_db" {
  value = [aws_security_group.security_group_app_to_db["app_to_db"].id]
}

output "subnet_public_web" {
  value = aws_subnet.subnet_public_web.*.id
}
output "subnet_private_app" {
  value = aws_subnet.subnet_private_app.*.id
}
output "subnet_private_db" {
  value = aws_subnet.subnet_private_db.*.id
}
output "subnet_public_bastion" {
  value = aws_subnet.subnet_public_bastion.*.id
}
