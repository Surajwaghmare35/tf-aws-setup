#-----------------------------------------CREATE A VPC---------------------------------------------

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr //Note: Assigned CIDR not need to be exist already in vpc
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_tag
  }
}

# Create IGW & attach-it to VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.igw_tag
  }
}

# Creating public, private-subnets in 'single' AZ

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = var.public_subnet_cidr
  #map_public_ip_on_launch = true //default is 'false' //make it
  tags = {
    Name = "${var.public_subnet_tag}-${data.aws_availability_zones.azs.names[0]}"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0] //ap-south-1a
  cidr_block        = var.private_subnet_cidr
  tags = {
    Name = "${var.private_subnet_tag}-${data.aws_availability_zones.azs.names[0]}"
  }
}

# Creating RT for Public Subnet
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0" //Traffic from Public Subnet reaches Internet via IGW
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = var.public_sub_rt
  }
}

# Assign tag to Main-RT of VPC
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = var.main_rt
  }
}

# Creating Vpc-Endpoint as S3-Gateway, for non NAT-G private-subnet
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway" //default
  #policy = "" //default Full-Access from VpcE-to-S3
  tags = {
    Name = var.vpc_s3_endpoint_tag
  }
}

# Creating RT for Private Subnet
resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.vpc.id // Create PrivateRT with default rule vpc_cidr-->local-search
  tags = {
    Name = "${var.private_sub_rt}-${data.aws_availability_zones.azs.names[0]}"
  }
}

## Creating Route table Association with Subnet's & vpc-S3 endpoint

# Attaching Public-RT to public-subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.PublicRT.id
}

# Attaching Private-RT to private-subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.PrivateRT.id
}

## Create Private-RT association & attach s3-G as endpoint with prefix_list_ids
resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.PrivateRT.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id //auto assign matches prefix_list_ids in RT
}

## Create a NAT-Gateway & attach EIP
#resource "aws_nat_gateway" "NAT_G" {
#  allocation_id = aws_eip.EIP.id
#  subnet_id     = aws_subnet.public.id
#  tags = {
#    Name = var.nat_gateway_tag
#  }
#  # To ensure proper ordering, it is recommended to add an explicit dependency
#  # on the Internet Gateway for the VPC.
#  depends_on = [aws_internet_gateway.IGW]
#}

## Note:Creation of default NACL with default in/out-bound-rule no:"100" for respctive VPC
## & assigning it to subnet's is taken-care by AWS. Manually we can create default ACL as follows:

resource "aws_default_network_acl" "ACL" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  #creating dynamic-block for "ingress" & "egress" rule
  dynamic "ingress" {
    for_each = [0]
    iterator = port
    content {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = port.value
      to_port    = port.value
    }
  }
  dynamic "egress" {
    for_each = [0]
    iterator = port
    content {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = port.value
      to_port    = port.value
    }
  }
  tags = {
    Name = var.default_acl_tag
  }
}

## Asiign NACL to Public/Private Subnet
resource "aws_network_acl_association" "public" {
  network_acl_id = aws_default_network_acl.ACL.id
  subnet_id      = aws_subnet.public.id
}
resource "aws_network_acl_association" "private" {
  network_acl_id = aws_default_network_acl.ACL.id
  subnet_id      = aws_subnet.private.id
}

### Note:To every-New VPC, auto-assign default-DHCP is taken-care by AWS
### Manually we assign default DHCP as follows

# Assign Default-dhcp to VPC
resource "aws_vpc_dhcp_options_association" "Assign-DHCP" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc.vpc.dhcp_options_id
}
