module "tf_instance" {
  source = "./instance"

  region = var.region

  #---st_1_vars
  iam_user                     = var.iam_user
  iam_user_tag                 = var.iam_user_tag
  iam_user_server_policy       = var.iam_user_server_policy
  iam_user_logRetention_policy = var.iam_user_logRetention_policy

  #---st_1_of_2_vars
  path_to_store_ak_sk = var.path_to_store_ak_sk

  #---st_2_vars
  iam_role             = var.iam_role
  iam_role_tag         = var.iam_role_tag
  iam_role_description = var.iam_role_description

  iam_role_inline_server_policy       = var.iam_role_inline_server_policy
  iam_role_inline_logRetention_policy = var.iam_role_inline_logRetention_policy
  iam_instance_profile                = var.iam_instance_profile

  #---st_3_vars
  key_pair_name                  = var.key_pair_name
  attach_local_pub_key_file_path = var.attach_local_pub_key_file_path
  key_pair_tag                   = var.key_pair_tag

  #---st_4_vars
  vpc_cidr = var.vpc_cidr
  vpc_tag  = var.vpc_tag

  igw_tag = var.igw_tag

  public_subnet_cidr  = var.public_subnet_cidr
  public_subnet_tag   = var.public_subnet_tag
  private_subnet_cidr = var.private_subnet_cidr
  private_subnet_tag  = var.private_subnet_tag

  public_sub_rt  = var.public_sub_rt
  main_rt        = var.main_rt
  private_sub_rt = var.private_sub_rt

  vpc_s3_endpoint_tag = var.vpc_s3_endpoint_tag

  #nat_gateway_tag = var.nat_gateway_tag

  default_acl_tag = var.default_acl_tag

  #---st_5_vars
  sg_name        = var.sg_name
  sg_description = var.sg_description
  sg_tag         = var.sg_tag

  default_sg_tag = var.default_sg_tag

  #---st_6_vars
  instance_type       = var.instance_type
  user_data_file_path = var.user_data_file_path
  root_volume_size    = var.root_volume_size
  root_volume_type    = var.root_volume_type

  spot_instance_id_tag = var.spot_instance_id_tag
  spot_I_name_tag      = var.spot_I_name_tag

  #eip_tag = var.eip_tag

  #   #---st_6_of_2_vars
  #   onDemand_I_name_tag = var.onDemand_I_name_tag
  #   #eip_tag = var.eip_tag

}

#-----------data output

output "MypublicIP" {
  value = module.tf_instance.MypublicIP
}
output "recent_ubuntu_20" {
  value = module.tf_instance.recent_ubuntu_ami
}

output "SPOT-Price" {
  value = module.tf_instance.SPOT-Price
}

#---st_6_output------------

output "InstanceIP" {
  value = module.tf_instance.InstanceIP
}
output "Spot-Req-ID" {
  value = module.tf_instance.Spot-Req-ID
}
output "Spot-InstanceID" {
  value = module.tf_instance.Spot-InstanceID
}

# output "public_EIP" {
#   value = module.tf_instance.public_EIP
# }

variable "client" {}

module "tf_s3" {
  source              = "./s3"
  client              = var.client
  region              = var.region
  iam_user            = module.tf_s3.iam_user
  access_key          = module.tf_s3.access_key
  secret_key          = module.tf_s3.secret_key
  path_to_store_ak_sk = var.path_to_store_ak_sk
  account_id          = module.tf_s3.account_id
  bucket              = module.tf_s3.cms_pri_bucket
}
