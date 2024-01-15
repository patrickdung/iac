locals {
  generic_vpc_tag_name = "${var.aws_region_shortform}-${var.environment}-${var.vpc_number}"
}

locals {
  security_group_internet_to_web = {
    public_web = {
      ## name        = "security_group_internet_to_web"
      name        = "secgroup-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-web"
      description = "Allow ingress from Internet to public subnet web tier"
      ingress = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          ## cidr_blocks = [var.allow_incoming_ssh_ip]
          cidr_blocks = var.allow_incoming_ssh_ip
        }
        http = {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        # icmp ping only 
        icmp = {
          from_port   = 8
          to_port     = -1
          protocol    = "icmp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

locals {
  security_group_internet_to_elb_public_web = {
    elb_public_web = {
      ## name        = "security_group_internet_to_web"
      name        = "secgroup-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-elb-public-web"
      description = "Allow ingress from Internet to public subnet ELB web tier"
      ingress = {
        http = {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        # icmp ping only 
        icmp = {
          from_port   = 8
          to_port     = -1
          protocol    = "icmp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

locals {
  security_group_db = {
    database = {
      name        = "secgroup-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-db"
      description = "Security Group for database tier"
      ingress = {
        pgsql = {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
        }
        mysql = {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
        }
        oracle = {
          from_port   = 1521
          to_port     = 1521
          protocol    = "tcp"
        }
        mssql = {
          from_port   = 1433
          to_port     = 1433
          protocol    = "tcp"
        }
      }
    }
  }
}

locals {
  security_group_web_to_db = {
    web_to_db = {
      name        = "secgroup-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-web-to-db"
      description = "Allow ingress from Web to DB"
      ingress = {
        pgsql = {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
        }
        mysql = {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
        }
        oracle = {
          from_port   = 1521
          to_port     = 1521
          protocol    = "tcp"
        }
        mssql = {
          from_port   = 1433
          to_port     = 1433
          protocol    = "tcp"
        }
      }
    }
  }
}

locals {
  security_group_app_to_db = {
    app_to_db = {
      name        = "secgroup-${var.aws_region_shortform}-${var.environment}-${var.vpc_number}-app-to-db"
      description = "Allow ingress from App to DB"
      ingress = {
        pgsql = {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          # cidr_blocks = ["0.0.0.0/0"]
        }
        mysql = {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          # cidr_blocks = ["0.0.0.0/0"]
        }
        oracle = {
          from_port   = 1521
          to_port     = 1521
          protocol    = "tcp"
          # cidr_blocks = ["0.0.0.0/0"]
        }
        mssql = {
          from_port   = 1433
          to_port     = 1433
          protocol    = "tcp"
          # cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
