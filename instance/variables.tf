variable "region" {}

#---------st_1_iam_users.tf vars--------------------
variable "iam_user" {}
variable "iam_user_tag" {}
variable "iam_user_server_policy" {}
variable "iam_user_logRetention_policy" {}

#---------ak, sk path vars---------
variable "path_to_store_ak_sk" {}

#----------iam role vars--------
variable "iam_role" {}
variable "iam_role_tag" {}
variable "iam_role_description" {}

#----------inline iam policy vars----------------
variable "iam_role_inline_server_policy" {}
variable "iam_role_inline_logRetention_policy" {}
variable "iam_instance_profile" {}

#------------key pair vars-------------------------
variable "key_pair_name" {}
variable "attach_local_pub_key_file_path" {}
variable "key_pair_tag" {}

#---------------vpc cidr & tags vars-------------
variable "vpc_cidr" {}
variable "vpc_tag" {}

#---------------igw tag vars------------------
variable "igw_tag" {}

#--------------subnet cidi & tags vars---------------
variable "public_subnet_cidr" {}
variable "public_subnet_tag" {}
variable "private_subnet_cidr" {}
variable "private_subnet_tag" {}

#----------------RT tag vars-------------
variable "public_sub_rt" {}
variable "main_rt" {}
variable "private_sub_rt" {}

variable "vpc_s3_endpoint_tag" {}

#variable "nat_gateway_tag" {}

variable "default_acl_tag" {}

#-------------sg tag vars-------------
variable "sg_name" {}
variable "sg_description" {}
variable "sg_tag" {}

variable "default_sg_tag" {}

#-------------spot -I tag vars--------------
variable "instance_type" {}
variable "user_data_file_path" {}
variable "root_volume_size" {}
variable "root_volume_type" {}

#-------use below when instace=spot----------#
variable "spot_instance_id_tag" {}
variable "spot_I_name_tag" {}

#-------use below when instace=onDemand----------#
#variable "onDemand_I_name_tag" {}

# variable "eip_tag" {} //use only when u want it.
