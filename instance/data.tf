##--------------------------------------------A/C-DATA-SOURCE----------------------------------------

# Fetching A/c Region
data "aws_region" "current" {}
#output "region" {
#  value = data.aws_region.current.name
#}  

# Fetching Aws A/c details as ID
data "aws_caller_identity" "current" {}
#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}

## NOW WE NOT USE THIS
data "aws_canonical_user_id" "current" {}
#output "canonical_user_id" {
#  value = data.aws_canonical_user_id.current.id
#} 

#----------------------------------------Fetching Public-ip-----------------------------------------

# Use http data-source to print public-ip
data "http" "my_ip" {
  url = "http://ifconfig.co"
}
output "MypublicIP" {
  value = data.http.my_ip.response_body
}


#------------------------------Fetching available iam role details----------------------------------

#data "aws_iam_role" "cwa" {
#  name = "EC2-CWA-Server-Policy"
#  #name_regex = "EC2-CWA-Server-Policy"
#}
#output "result" {
#  value = data.aws_iam_role.cwa
#}

#------------------------------Fetching available instance_profile details-------------------------

#data "aws_iam_instance_profile" "cwa" {
#  name = "EC2-CWA-Server-Policy"
#} 
#output "result1" {
#  value = data.aws_iam_instance_profile.cwa
#}

#---------------------------------Fetching aws-managed cwa-server-policy----------------------------

data "aws_iam_policy" "cwa_server" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
#value = data.aws_iam_policy.cwa_server.policy

#---------------Fetching available availability_zones in region using data source-------------------

data "aws_availability_zones" "azs" {
  state                  = "available"
  all_availability_zones = true
}
#value = data.aws_availability_zones.azs.names[0]

#------------------------Fetching latest ubuntu-ami using aws-data-source---------------------------
locals {
  ubuntu_18 = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  ubuntu_20 = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

data "aws_ami" "ubuntu" {
  #executable_users = ["a/c-id"] //default is "self"
  most_recent = true
  #name_regex  = "Ubuntu Server 20.04 LTS (HVM), SSD" // default is "^myami-\\d{3}"
  owners = ["099720109477"] //default is "self"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }
}
output "recent_ubuntu_ami" {
  value = data.aws_ami.ubuntu.image_id
}

#----------------------------------Fetching latest Spot-Price---------------------------------------

data "aws_ec2_spot_price" "price" {
  instance_type     = "t2.micro"
  availability_zone = data.aws_availability_zones.azs.names[0]
  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}
output "SPOT-Price" {
  value = data.aws_ec2_spot_price.price.spot_price
}

##--------------------------------------Fetching Ec2-publicIP --------------------------------

data "aws_instance" "u-ami" {
  #instance_id = "i-0d8a924739828ea57" //paste Instance-id if have
  #instance_id = aws_instance.prod.id //use when 'instance = onDemand'
  instance_id = aws_spot_instance_request.spot.spot_instance_id //use when 'instance = spot'
}
# output "InstanceIP" {
#   value = data.aws_instance.u-ami.public_ip
# }
