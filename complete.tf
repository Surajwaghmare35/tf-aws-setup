##------------------------------------Provider Configuration-----------------------------------------
#
### Configure the Terraform Provider
#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "4.31.0"
#    }
#  }
#}
#
### Configure the AWS Provider
#provider "aws" {
#  region                   = "ap-south-1" //(hardCoded-recommended)
#  shared_config_files      = ["/home/suraj/.aws/config"]
#  shared_credentials_files = ["/home/suraj/.aws/credentials"]
#  profile                  = "default"
#  #access_key = "xxxxxxxxxx"	//replace xx with AK-valuse	//20-char(string)
#  #secret_key = "xxxxxxxxxxxxxxxxxxxx" ///replace xx with SK-valuse	//40-char(string)
#}
#
##--------------------------------------AWS A/C DATA-SOURCE------------------------------------------
#
### Fetching A/c Region
#data "aws_region" "current" {}
##output "region" {
##  value = data.aws_region.current.name
##
#
### Fetching Aws A/c details as ID
#data "aws_caller_identity" "current" {}
##output "account_id" {
##  value = data.aws_caller_identity.current.account_id
##}
##
### NOW WE NOT USE THIS
#data "aws_canonical_user_id" "current" {}
##output "canonical_user_id" {
##  value = data.aws_canonical_user_id.current.id
##}
#
## Use http data-source to print public-ip
#data "http" "my_ip" {
#  url = "http://ifconfig.co"
#}
#output "MypublicIP" {
#  value = data.http.my_ip.response_body
#}
#
##-----------------------------------------CREATE AN IAM USER----------------------------------------
#
### Create IAM User with gui/cli access with inline-policy
#
##NOTE: If policies are attached to the user via the 'aws_iam_policy_attachment resource' and you are modifying the 'user name' or 'path', the 'force_destroy' argument must be set to 'true' and applied before attempting the operation 'otherwise' you will encounter a 'DeleteConflict error'. The 'aws_iam_user_policy_attachment resource' (recommended) does not have this requirement.
#
#resource "aws_iam_user" "cwa" {
#  name          = "onPremise-CWA1"
#  path          = "/"
#  force_destroy = true //default is "false"
#
#  tags = {
#    name = "onPremise-CWA-server-policy"
#  }
#}
#
## Generate access_key to allow cli access
#resource "aws_iam_access_key" "cwa" {
#  user   = aws_iam_user.cwa.name
#  status = "Active"
#}
#
### Allow console-management-access //make'#'to allow only CLI
##resource "aws_iam_user_login_profile" "cwa" {
##  user = aws_iam_user.cwa.name
##  #pgp_key = "keybase:some_person_that_exists"
##  password_reset_required = false //<--default, if "true" User create new password at next signIN
##}
#
## Store AK,SK locally in json-file
#locals {
#  credentials = {
#    "User name" = "${aws_iam_user.cwa.name}"
#    #"Password"           = "${aws_iam_user_login_profile.cwa.password}" //make'#'to allow only CLI
#    "region"             = "ap-south-1"
#    "Access Key ID"      = "${aws_iam_access_key.cwa.id}"
#    "Secret Access Key"  = "${aws_iam_access_key.cwa.secret}"
#    "Console login link" = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console" //default to 'A/c'
#  }
#}
#
#resource "local_file" "outputdata" {
#  filename        = "${path.module}/${aws_iam_user.cwa.name}.json"
#  content         = jsonencode(local.credentials)
#  file_permission = "0664" //default 0777
#}
#
## Fetching aws-managed cwa-server-policy
#data "aws_iam_policy" "cwa_server" {
#  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#}
#
#resource "aws_iam_user_policy" "cwa_server" {
#  name   = "onPremise-CWA-server-policy"
#  user   = aws_iam_user.cwa.name
#  policy = data.aws_iam_policy.cwa_server.policy //attaching aws-managed cwa-server-policy
#}
#
## Create & attach onPremise-CWA-logRetention policy
#resource "aws_iam_user_policy" "cwa_logRetention" {
#  name   = "onPremise-CWA-logRetention"
#  user   = aws_iam_user.cwa.name
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": "logs:PutRetentionPolicy",
#            "Resource": "*"
#        }
#    ]
#}
#EOF
#}
#
##-----------------------------------------CREATE AN IAM ROLE---------------------------------------
#
## Fetching available iam role details
##data "aws_iam_role" "cwa" {
##  name = "EC2-CWA-Server-Policy"
##  #name_regex = "EC2-CWA-Server-Policy"
##}
##output "result" {
##  value = data.aws_iam_role.cwa
##}
##
### Fetching available instance_profile details
##data "aws_iam_instance_profile" "cwa" {
##  name = "EC2-CWA-Server-Policy"
##}
##output "result1" {
##  value = data.aws_iam_instance_profile.cwa
##}
#
## Creating iam role
#resource "aws_iam_role" "cwa" {
#  name = "EC2-CWA-Server-Policy1"
#  #assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json # (not shown)
#  force_detach_policies = true //default is "false"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Action = "sts:AssumeRole"
#        Effect = "Allow"
#        Sid    = ""
#        Principal = {
#          Service = "ec2.amazonaws.com"
#        }
#      },
#    ]
#  })
#  tags = {
#    "Name" = "EC2-CWA-Server-Policy1"
#  }
#  inline_policy {
#    name   = "EC2-CWA-Server-Policy1"
#    policy = data.aws_iam_policy.cwa_server.policy
#  }
#  inline_policy {
#    name = "EC2-CWA-logRetention1"
#    #policy = aws_iam_user_policy.cwa_logRetention.policy
#    policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": "logs:PutRetentionPolicy",
#            "Resource": "*"
#        }
#    ]
#}
#EOF
#  }
#  #managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
#  description = "Allows EC2 instances to call AWS Cloudwatch Log services"
#}
#
## Manually create Instance profile & attach to IAM-role
#resource "aws_iam_instance_profile" "cwa" {
#  name = "EC2-CWA-Server-Policy1"
#  role = aws_iam_role.cwa.name
#}
#
##------------------------------CREATE A KEY-PAIR USINF TF (not-recommended)------------------------
#
####STEP1
### Creating new RSA-ssh public-private key of size 4096 bits using tf
###use of this method id not valid to import, coz pub-pri-key content stote in .tfstate file
##resource "tls_private_key" "rsa" {
##  algorithm = "RSA"
##  rsa_bits  = 4096
##}
#
####STEP2
### Storing tls_private_key on local .ssh/
##resource "local_file" "local_tf_rsa" {
##  content = tls_private_key.rsa.private_key_pem
##  #filename = "${path.module}/tf_rsa" //file store in relative-path
##  filename             = pathexpand("~/.ssh/tf_rsa") //file store in absolute-path
##  directory_permission = "0777"
##  file_permission      = "0400" //default 0777
##}
#
##---------------------------IMPORT A LOCAL KEY-PAIR (recommended)-----------------------------------
#
## Importing tf/local-pub-key on aws-ec2 //recommended method
#resource "aws_key_pair" "tf_key1" {
#  key_name   = "Ubuntu-tf"
#  public_key = file("~/.ssh/id_rsa.pub") //use this to import local-pub-key
#  #public_key = tls_private_key.rsa.public_key_openssh //use this to import tf-pub-key
#  tags = {
#    key-type = "local-pub-key"
#  }
#}
#
##-----------------------------------------CREATE A VPC---------------------------------------------
#
## Create a VPC
#resource "aws_vpc" "vpc" {
#  cidr_block           = "10.1.0.0/16" //Note: Assigned CIDR not need to be exist already in vpc
#  instance_tenancy     = "default"
#  enable_dns_support   = true
#  enable_dns_hostnames = true
#  tags = {
#    Name = "project1-vpc"
#  }
#}
#
## Create IGW & attach-it to VPC
#resource "aws_internet_gateway" "IGW" {
#  vpc_id = aws_vpc.vpc.id
#  tags = {
#    Name = "project1-igw"
#  }
#}
#
## Fetching available availability_zones in region using data source
#data "aws_availability_zones" "azs" {
#  state                  = "available"
#  all_availability_zones = true
#}
#
## Creating public, private-subnets in 'single' AZ
#resource "aws_subnet" "public" {
#  vpc_id            = aws_vpc.vpc.id
#  availability_zone = data.aws_availability_zones.azs.names[0]
#  cidr_block        = "10.1.0.0/20"
#  #map_public_ip_on_launch = true //default is 'false' //make it
#  tags = {
#    Name = "project1-subnet-public1-${data.aws_availability_zones.azs.names[0]}"
#  }
#}
#resource "aws_subnet" "private" {
#  vpc_id            = aws_vpc.vpc.id
#  availability_zone = data.aws_availability_zones.azs.names[0] //ap-south-1a
#  cidr_block        = "10.1.128.0/20"
#  tags = {
#    Name = "project1-subnet-private1-${data.aws_availability_zones.azs.names[0]}"
#  }
#}
#
## Creating RT for Public Subnet
#resource "aws_route_table" "PublicRT" {
#  vpc_id = aws_vpc.vpc.id
#  route {
#    cidr_block = "0.0.0.0/0" //Traffic from Public Subnet reaches Internet via IGW
#    gateway_id = aws_internet_gateway.IGW.id
#  }
#  tags = {
#    Name = "project1-rbt-public"
#  }
#}
#
## Assign tag to Main-RT of VPC
#resource "aws_default_route_table" "main-rtb" {
#  default_route_table_id = aws_vpc.vpc.default_route_table_id
#  tags = {
#    Name = "main-rtb-project1"
#  }
#}
#
## Creating Vpc-Endpoint as S3-Gateway, for non NAT-G private-subnet
#resource "aws_vpc_endpoint" "s3" {
#  vpc_id            = aws_vpc.vpc.id
#  service_name      = "com.amazonaws.ap-south-1.s3"
#  vpc_endpoint_type = "Gateway" //default
#  #policy = "" //default Full-Access from VpcE-to-S3
#  tags = {
#    Name = "project1-vpce-s3"
#  }
#}
#
## Creating RT for Private Subnet
#resource "aws_route_table" "PrivateRT" {
#  vpc_id = aws_vpc.vpc.id // Create PrivateRT with default rule vpc_cidr-->local-search
#  tags = {
#    Name = "project1-rbt-private1-${data.aws_availability_zones.azs.names[0]}"
#  }
#}
#
### Creating Route table Association with Subnet's & vpc-S3 endpoint
#
## Attaching Public-RT to public-subnet
#resource "aws_route_table_association" "public" {
#  subnet_id      = aws_subnet.public.id
#  route_table_id = aws_route_table.PublicRT.id
#}
#
## Attaching Private-RT to private-subnet
#resource "aws_route_table_association" "private" {
#  subnet_id      = aws_subnet.private.id
#  route_table_id = aws_route_table.PrivateRT.id
#}
#
### Create Private-RT association & attach s3-G as endpoint with prefix_list_ids
#resource "aws_vpc_endpoint_route_table_association" "s3" {
#  route_table_id  = aws_route_table.PrivateRT.id
#  vpc_endpoint_id = aws_vpc_endpoint.s3.id //auto assign matches prefix_list_ids in RT
#}
#
### Create An Elastic-IP
##resource "aws_eip" "EIP" {
##  public_ipv4_pool = "amazon"
##  vpc              = true
##}
#
### Create a NAT-Gateway & attach EIP
##resource "aws_nat_gateway" "NAT_G" {
##  allocation_id = aws_eip.EIP.id
##  subnet_id     = aws_subnet.public.id
##  tags = {
##    Name = "gw-NAT"
##  }
##  # To ensure proper ordering, it is recommended to add an explicit dependency
##  # on the Internet Gateway for the VPC.
##  depends_on = [aws_internet_gateway.IGW]
##}
#
### Note:Creation of default NACL with default in/out-bound-rule no:"100" for respctive VPC
### & assigning it to subnet's is taken-care by AWS. Manually we can create default ACL as follows:
#
#resource "aws_default_network_acl" "ACL" {
#  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
#
#  #creating dynamic-block for "ingress" & "egress" rule
#  dynamic "ingress" {
#    for_each = [0]
#    iterator = port
#    content {
#      protocol   = "-1"
#      rule_no    = 100
#      action     = "allow"
#      cidr_block = "0.0.0.0/0"
#      from_port  = port.value
#      to_port    = port.value
#    }
#  }
#  dynamic "egress" {
#    for_each = [0]
#    iterator = port
#    content {
#      protocol   = "-1"
#      rule_no    = 100
#      action     = "allow"
#      cidr_block = "0.0.0.0/0"
#      from_port  = port.value
#      to_port    = port.value
#    }
#  }
#  tags = {
#    Name = "project1-acl"
#  }
#}
#
### Asiign NACL to Public/Private Subnet
#resource "aws_network_acl_association" "public" {
#  network_acl_id = aws_default_network_acl.ACL.id
#  subnet_id      = aws_subnet.public.id
#}
#resource "aws_network_acl_association" "private" {
#  network_acl_id = aws_default_network_acl.ACL.id
#  subnet_id      = aws_subnet.private.id
#}
#
#### Note:To every-New VPC, auto-assign default-DHCP is taken-care by AWS
#### Manually we assign default DHCP as follows
#
## Assign Default-dhcp to VPC
#resource "aws_vpc_dhcp_options_association" "Assign-DHCP" {
#  vpc_id          = aws_vpc.vpc.id
#  dhcp_options_id = aws_vpc.vpc.dhcp_options_id
#}
#
## Creating an SG with ingress-Egress rule
#resource "aws_security_group" "tf_sg1" {
#  name        = "Ubuntu-tf-sg"
#  description = "Allow SSH inbound traffic" //default is "Managed by Terraform"
#  vpc_id      = aws_vpc.vpc.id              //assign new vpc_id onlyIF vpc != default
#  #if we not mentioned vpc id,its create an sg in default vpc
#  #vpc_id = "vpc-0f69e8cb579ca335e" //main vpc
#
#  #creating dynamic-block for "ingress" & "egress" rule
#  dynamic "ingress" {
#    for_each = [22]
#    iterator = port
#    content {
#      #description = ""
#      from_port = port.value
#      to_port   = port.value
#      protocol  = "tcp"
#      #cidr_blocks = ["0.0.0.0/0"]
#      cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] //chomp() remove'\n' at EOstring
#      #cidr_blocks = [aws_vpc.vpc.cidr_block]
#    }
#  }
#  dynamic "egress" {
#    for_each = [0]
#    iterator = port
#    content {
#      #description = ""
#      from_port   = port.value
#      to_port     = port.value
#      protocol    = "-1" //all
#      cidr_blocks = ["0.0.0.0/0"]
#      #ipv6_cidr_blocks = ["::/0"] //optionl ipv6
#    }
#  }
#  tags = {
#    Name = "Ubuntu-tf-sg"
#  }
#}
#
## Assigning tag to Default-SG by keeping default ingress-Egress rule
#resource "aws_default_security_group" "default-sg" {
#  vpc_id = aws_vpc.vpc.id
#
#  #creating dynamic-block for "ingress" & "egress" rule
#  dynamic "ingress" {
#    for_each = [0]
#    iterator = port
#    content {
#      from_port = port.value
#      to_port   = port.value
#      protocol  = "-1"
#      self      = true //adding sg itselt as a source in inbound
#    }
#  }
#  dynamic "egress" {
#    for_each = [0]
#    iterator = port
#    content {
#      from_port   = port.value
#      to_port     = port.value
#      protocol    = "-1" //all
#      cidr_blocks = ["0.0.0.0/0"]
#    }
#  }
#  tags = {
#    Name = "default-project1-sg"
#  }
#}
#
##------------------------------------CREATE AN EC2 INSTANCE-----------------------------------------
#
## Fetching latest ubuntu-ami using aws-data-source
#data "aws_ami" "ubuntu" {
#  #executable_users = ["a/c-id"] //default is "self"
#  most_recent = true
#  #name_regex  = "Ubuntu Server 20.04 LTS (HVM), SSD" // default is "^myami-\\d{3}"
#  owners = ["099720109477"] //default is "self"
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "root-device-type"
#    values = ["ebs"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  filter {
#    name   = "architecture"
#    values = ["x86_64"]
#  }
#
#  filter {
#    name   = "ena-support"
#    values = ["true"]
#  }
#
#  filter {
#    name   = "owner-alias"
#    values = ["amazon"]
#  }
#
#  filter {
#    name   = "is-public"
#    values = ["true"]
#  }
#}
#output "recent_ubuntu" {
#  value = data.aws_ami.ubuntu.image_id
#}
#
## Fetching latest Spot-Price
#data "aws_ec2_spot_price" "price" {
#  instance_type     = "t3.micro"
#  availability_zone = data.aws_availability_zones.azs.names[0]
#  filter {
#    name   = "product-description"
#    values = ["Linux/UNIX"]
#  }
#}
#output "SPOT-Price" {
#  value = data.aws_ec2_spot_price.price.spot_price
#}
#
### TO Request a spot instance follow this resource
#resource "aws_spot_instance_request" "spot" {
#  ami           = data.aws_ami.ubuntu.image_id
#  instance_type = "t2.micro"
#  tags = {
#    Name = "Spot-Ubuntu1-20.04" //its applied to Spot Req-ID not Spot-I ID--manually do using console
#  }
#  spot_price = data.aws_ec2_spot_price.price.spot_price
#  #spot_price           = "0.0037" #make it'#' or assign price by checking on aws-console as per AZ  
#  spot_type            = "one-time"
#  wait_for_fulfillment = true //default "false"
#  #}
#
#
#  ###To Create On-Demand Instance Follow below one:
#  #
#  ### Creating "Ubuntu-20.04" On-Demand instance
#  #resource "aws_instance" "prod" {
#  #  ami = data.aws_ami.ubuntu.image_id //auto-assign (recommended) //hardCoded not-recommended
#  #
#  #  instance_type = "t2.micro" //hardCoded (recommended)
#  #  tags = {
#  #    Name = "Ubuntu-20.04" // name of instance
#  #  }
#
#  subnet_id = aws_subnet.public.id //Assign subnet_ID only when vpc!=default
#
#  #If you are creating Instances in a VPC, use vpc_security_group_ids instead.
#  vpc_security_group_ids = ["${aws_security_group.tf_sg1.id}"]
#
#  associate_public_ip_address = true
#
#  private_dns_name_options {
#    enable_resource_name_dns_a_record    = true
#    enable_resource_name_dns_aaaa_record = false
#    hostname_type                        = "ip-name"
#  }
#
#  capacity_reservation_specification {
#    capacity_reservation_preference = "open" //default -->alternative=none
#  }
#
#  instance_initiated_shutdown_behavior = "stop" //default alternative=terminate
#  hibernation                          = false  //default
#  disable_api_stop                     = false  //If "true", enables Instance Stop Protection.
#  disable_api_termination              = false  //If "true", enables Instance Termination Protection.
#
#  iam_instance_profile = aws_iam_instance_profile.cwa.name
#
#  monitoring = false //if "true" will detailed monitor
#
#  tenancy = "default"
#
#  credit_specification {
#    cpu_credits = "standard" //default for t2-instance-type, unlimited for t3>=
#  }
#
#  ## Auto-assigning of ENI-card (with-publicIP) to selected subnet is taken-care by AWS
#
#  metadata_options {
#    http_endpoint               = "enabled"  //default
#    http_tokens                 = "optional" //default -->alternative=required
#    http_put_response_hop_limit = 1          //default
#    instance_metadata_tags      = "disabled" //default
#  }
#
#  #user_data = filebase64("${path.module}/example.sh")
#
#  key_name = aws_key_pair.tf_key1.key_name
#
#  root_block_device {
#    volume_size           = 8
#    volume_type           = "gp2"
#    delete_on_termination = true
#    encrypted             = false
#  }
#}
#
### Use only if instance=spot: 'aws_ec2_tag' resource to assign tag to Spot-I-id
#resource "aws_ec2_tag" "Spot-I-Name" {
#  resource_id = aws_spot_instance_request.spot.spot_instance_id
#  key         = "Name"
#  value       = "Spot-Ubuntu1-20.04"
#}
#
### Fetching Ec2-publicIP 
#data "aws_instance" "u-ami" {
#  #instance_id = "i-0d8a924739828ea57"
#  #instance_id = aws_instance.prod.id
#  instance_id = aws_spot_instance_request.spot.spot_instance_id
#}
#output "InstanceIP" {
#  value = data.aws_instance.u-ami.public_ip
#}
#
### SPOT-I Details
#output "Spot-InstanceID" {
#  value = aws_spot_instance_request.spot.spot_instance_id
#}
#output "Spot-Req-ID" {
#  value = aws_spot_instance_request.spot.id
#}
#
##Note: about count meta argument
##count         = 0 # if we set this then tf ingnore this resource creation
