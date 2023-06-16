
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_main_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = var.project
    Group = var.project
  }
}

# Kong: We could pot. use an egress-only gateway, but the security group is easier to manage
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.project
    Group = var.project
  }
}


resource "aws_subnet" "primary" {
  vpc_id = aws_vpc.main.id

  cidr_block = var.vpc_primary_subnet_cidr

  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.environment}-primary-0"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id = aws_vpc.main.id

  cidr_block = var.vpc_secondary_subnet_cidr

  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.environment}-secondary-16"
  }
}

locals {
  # make sure we only use the tertiary subnet if the region allows for it
  count_tertiary = length(data.aws_availability_zones.available.names) > 2 ? 1 : 0
}

resource "aws_subnet" "tertiary" {
  # this count makes it a list, since in theory it could contain multiple ones
  # this is the only way in terraform to create optional elements
  count = local.count_tertiary

  vpc_id = aws_vpc.main.id

  cidr_block = var.vpc_tertiary_subnet_cidr

  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.environment}-tertiary-32"
  }
}

# route table for vpc
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

# route table association for primary subnet
resource "aws_route_table_association" "primary" {
  subnet_id      = aws_subnet.primary.id
  route_table_id = aws_route_table.rt.id
}

# route table association for secondary subnet
resource "aws_route_table_association" "secondary" {
  subnet_id      = aws_subnet.secondary.id
  route_table_id = aws_route_table.rt.id
}

# route table association for tertiary subnet
resource "aws_route_table_association" "tertiary" {
  count = local.count_tertiary

  subnet_id      = aws_subnet.tertiary[0].id
  route_table_id = aws_route_table.rt.id
}
