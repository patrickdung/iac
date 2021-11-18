# --- vpc/main.tf ---

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tag_name = "${var.aws_region_shortform}-${var.environment}-${var.vpc_number}"
}

resource "aws_vpc" "vpc" {

  lifecycle {
    create_before_destroy = true
  }

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    ## Name = "${var.aws_region_shortform}.${var.environment}.${var.vpc_number}"
    Name = "vpc-${local.tag_name}"
    Environment = "${var.environment}"
  }
}

# --- Subnets ---
resource "aws_subnet" "subnet_public_web" {
  vpc_id = aws_vpc.vpc.id
  count = length("${var.public_web_cidrs}")
  cidr_block = "${var.public_web_cidrs[count.index]}"
  map_public_ip_on_launch = true

  # Need to match with the region that you are using
  ##availability_zone = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
 
  tags = {
    ## subnet-apne2-az(1/2/3)-dev-(web/app/db)-01
    ## "subnet-${RegionShortForm}-${AZ}-${Environment}-${Function}-${VPCNumber}"
    Name = "subnet-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-web-${var.vpc_number}"
    Environment = "${var.environment}"
  } 
}

resource "aws_subnet" "subnet_private_app" {
  vpc_id = aws_vpc.vpc.id
  count = length("${var.private_app_cidrs}")
  cidr_block = "${var.private_app_cidrs[count.index]}"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
 
  tags = {
    Name = "subnet-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-app-${var.vpc_number}"
    Environment = "${var.environment}"
  } 
}

resource "aws_subnet" "subnet_private_db" {
  vpc_id = aws_vpc.vpc.id
  count = length("${var.private_db_cidrs}")
  cidr_block = "${var.private_db_cidrs[count.index]}"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
 
  tags = {
    Name = "subnet-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-db-${var.vpc_number}"
    Environment = "${var.environment}"
  } 
}

resource "aws_subnet" "subnet_public_bastion" {
  vpc_id = aws_vpc.vpc.id
  count = length("${var.public_bastion_cidrs}")
  cidr_block = "${var.public_bastion_cidrs[count.index]}"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
 
  tags = {
    Name = "subnet-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-bastion-${var.vpc_number}"
    Environment = "${var.environment}"
  } 
}

# --- End of subnets ---

# IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-${local.tag_name}"
    Environment = "${var.environment}"
  }
} 

resource "aws_route_table" "routetable_public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "routetbl-public-${local.tag_name}"
  }
}

resource "aws_route" "route_public_defaultroute_ipv4" {
  route_table_id         = aws_route_table.routetable_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
  depends_on = [aws_route_table.routetable_public,
               aws_internet_gateway.internet_gateway
  ]
}

resource "aws_route_table_association" "routetable_association_web" {
  count = length(var.public_web_cidrs)
  subnet_id = "${aws_subnet.subnet_public_web[count.index].id}"
  route_table_id = aws_route_table.routetable_public.id
}

resource "aws_route_table_association" "routetable_association_bastion" {
  count = length(var.public_bastion_cidrs)
  subnet_id = "${aws_subnet.subnet_public_bastion[count.index].id}"
  route_table_id = aws_route_table.routetable_public.id
}

# --- NAT for private subnets ---
# Assume number of private subnets for app and db is the same
resource "aws_eip" "eip_nat_gateway" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
  vpc = true
  tags = {
    # Name = "eip-nat-gateway-${local.tag_name}"
    Name = "eip-nat-gateway-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-${var.vpc_number}"
    Environment = "${var.environment}"
  }
}

# resource "aws_internet_gateway" "internet_gateway_nat" {
#   count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name = "igw-nat-${local.tag_name}"
#   }
# }

# This is the public subnet which the NAT GW would be created
resource "aws_nat_gateway" "nat_gateway" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
  allocation_id = "${aws_eip.eip_nat_gateway[count.index].id}"
  subnet_id = "${aws_subnet.subnet_public_web[count.index].id}"
    # aws_internet_gateway.internet_gateway_nat
  depends_on = [
    aws_eip.eip_nat_gateway
  ]
  tags = {
    Name = "nat-gateway-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-${var.vpc_number}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "routetable_private" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "routetbl-private-${data.aws_availability_zones.available.zone_ids[count.index]}-${var.environment}-${var.vpc_number}"
  }
}

# default route for NAT GW
resource "aws_route" "route_private_defaultroute_ipv4" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
  route_table_id         = aws_route_table.routetable_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  ##nat_gateway_id         = aws_internet_gateway.internet_gateway_nat[count.index].id
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
               # aws_internet_gateway.internet_gateway_nat
  depends_on = [aws_route_table.routetable_private,
               aws_nat_gateway.nat_gateway
  ]
}

resource "aws_route_table_association" "routetable_association_nat_app" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_app_cidrs}") : 0
  subnet_id = "${aws_subnet.subnet_private_app[count.index].id}"
  route_table_id = aws_route_table.routetable_private[count.index].id
}

resource "aws_route_table_association" "routetable_association_nat_db" {
  count = var.create_natgw_for_private_subnets ? length("${var.private_db_cidrs}") : 0
  subnet_id = "${aws_subnet.subnet_private_db[count.index].id}"
  route_table_id = aws_route_table.routetable_private[count.index].id
}

# --- end of NAT for private subnets ---

# --- Security Group ---
resource "aws_security_group" "security_group_internet_to_web" {
  for_each    = var.security_group_internet_to_web
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = each.value.name
  }

  # Internet to Web Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_group_db" {
  for_each    = var.security_group_db
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = each.value.name
  }

  # DB Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      # cidr_blocks = ingress.value.cidr_blocks
      cidr_blocks = concat(var.public_web_cidrs, var.private_app_cidrs)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_group_web_to_db" {
  for_each    = var.security_group_web_to_db
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = each.value.name
  }

  # Web to DB Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      # cidr_blocks = ingress.value.cidr_blocks
      cidr_blocks = var.public_web_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_group_app_to_db" {
  for_each    = var.security_group_app_to_db
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = each.value.name
  }

  # App to DB Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      # cidr_blocks = ingress.value.cidr_blocks
      cidr_blocks = var.private_app_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# -- end of Security Groups ---

resource "aws_db_subnet_group" "db_subnetgroup" {
  count      = var.db_subnetgroup ? 1 : 0
  name       = "db-subnetgroup-${local.tag_name}"
  subnet_ids = aws_subnet.subnet_private_db.*.id
  tags = {
    Name = "db-subnetgroup-${local.tag_name}"
  }
}
