variable "region" {
  type    = string
  default = "eu-west-1" //change as per ur choise!
}

#-----------------------------------iam usr var to allow cli---------------------------------------

variable "iam_user" {
  type    = string
  default = "onPremise-CWA1"
}
variable "iam_user_tag" {
  type    = string
  default = "onPremise-CWA1-server-policy"
}
variable "iam_user_server_policy" {
  type    = string
  default = "onPremise-CWA1-server-policy"
}
variable "iam_user_logRetention_policy" {
  type    = string
  default = "onPremise-CWA1-logRetention"
}

#Note:
#-------the policy attached to logRetantion is (hard-codded)
#-------To Allow GuI go to st_1_iam_users.tf ,!# on console-code & password line in
#------ st_1_of_2_store_AK_SK_locally.tf

#--------path to store ak,sk of iam_user locally---------------

variable "path_to_store_ak_sk" {
  type    = string
  default = "~/applications/tf-aws-setup/" //change as per ur choise!
}

#---------------------------------------------iam role var-----------------------------------------

variable "iam_role" {
  type    = string
  default = "EC2-CWA-Server-Policy1"
}
variable "iam_role_tag" {
  type    = string
  default = "EC2-CWA-Server-Policy1"
}
variable "iam_role_description" {
  type    = string
  default = "Allows EC2 instances to call AWS Cloudwatch Log services"
}
#-----to attached managed policy use managed_policy_arns attribute------

#-----------------------attaching inline policy-------------------------

variable "iam_role_inline_server_policy" {
  type    = string
  default = "EC2-CWA-Server-Policy1"
}
variable "iam_role_inline_logRetention_policy" {
  type    = string
  default = "EC2-CWA-logRetention1"
}

#-----------------------attaching instance profile-----------------------

variable "iam_instance_profile" {
  type    = string
  default = "EC2-CWA-Server-Policy1"
}

#--------------------tls-key-pair var (not-recommended)------------------
# variable "path_to_stote_tls_pri_key" {
#   type    = string
#   default = "~/.ssh/tls_rsa" //syntax: /path/file-name
# }

#--------------------local-key-pair var (recommended)--------------------

variable "key_pair_name" {
  type    = string
  default = "Ubuntu-tf"
}
variable "attach_local_pub_key_file_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub" //syntax: /local/key.pub path   //change as per ur choise!
}
variable "key_pair_tag" {
  type    = string
  default = "local-pub-key"
}

#-----------------------------------------VPC cidr & tags------------------------------------------
variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "vpc_tag" {
  type    = string
  default = "project1-vpc"
}

#------------igw tag---------------------#
variable "igw_tag" {
  type    = string
  default = "project1-igw"
}

#--------------subnet cidr & tag----------#

variable "public_subnet_cidr" {
  type    = string
  default = "10.1.0.0/20"
}
variable "public_subnet_tag" {
  type    = string
  default = "project1-subnet-public1"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.1.128.0/20"
}
variable "private_subnet_tag" {
  type    = string
  default = "project1-subnet-private1"
}

#-----------------RT tag------------------#
variable "public_sub_rt" {
  type    = string
  default = "project1-rbt-public"
}
variable "main_rt" {
  type    = string
  default = "main-rbt-project1"
}
variable "private_sub_rt" {
  type    = string
  default = "project1-rbt-private1"
}

variable "vpc_s3_endpoint_tag" {
  type    = string
  default = "project1-vpce-s3"
}

# variable "nat_gateway_tag" {
#   type    = string
#   default = "gw-NAT"
# }

variable "default_acl_tag" {
  type    = string
  default = "project1-acl"
}

#-----------------SG tag-----------------#

variable "sg_name" {
  type    = string
  default = "Ubuntu-tf-sg"
}
variable "sg_description" {
  type    = string
  default = "Allow SSH inbound traffic"
}
variable "sg_tag" {
  type    = string
  default = "Ubuntu-tf-sg"
}

variable "default_sg_tag" {
  type    = string
  default = "default-project1-sg"
}

#-------------spot instance tag-----------#

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "user_data_file_path" {
  type    = string
  default = "~/applications/tf-aws-setup/instance/bash.sh" //change as per ur choise!
}
variable "root_volume_size" {
  type    = number
  default = 8
}
variable "root_volume_type" {
  type    = string
  default = "gp2"
}

variable "spot_instance_id_tag" {
  type    = string
  default = "Spot-Ubuntu1-20.04"
}
variable "spot_I_name_tag" { //to use onDemand make'#' on spot_id/name tag
  type    = string
  default = "Spot-Ubuntu1-20.04" //also on ec2-public id in data.tf
}

# variable "onDemand_I_name_tag" {
#   type    = string
#   default = "Ubuntu1-20.04"
# }

# #-----when instance is runnig make '!#' this var to use it for EIP at last
# variable "eip_tag" {
#   type    = string
#   default = "project1-spot-ec2-eip"
# }
