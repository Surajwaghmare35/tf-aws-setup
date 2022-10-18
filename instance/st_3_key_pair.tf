#------------------------------CREATE A KEY-PAIR USINF TF (not-recommended)------------------------

# ##STEP1
# # Creating new RSA-ssh public-private key of size 4096 bits using tf
# #use of this method id not valid to import, coz pub-pri-key content stote in .tfstate file
# resource "tls_private_key" "rsa" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# ##STEP2
# # Storing tls_private_key on local .ssh/
# resource "local_file" "local_tf_rsa" {
#   content = tls_private_key.rsa.private_key_pem
#   #filename = "${path.module}/tf_rsa" //file store in relative-path
#   #filename             = pathexpand("~/.ssh/tls_rsa") //file store in absolute-path
#   filename             = pathexpand("${var.path_to_stote_tls_pri_key}") //file store in absolute-path
#   directory_permission = "0777"
#   file_permission      = "0400" //default 0777
# }

#---------------------------IMPORT A LOCAL KEY-PAIR (recommended)-----------------------------------

# Importing tf/local-pub-key on aws-ec2 //recommended method
resource "aws_key_pair" "tf_key1" {
  key_name = var.key_pair_name
  #public_key = file("~/.ssh/id_rsa.pub") //use this to import local-pub-key
  public_key = file("${var.attach_local_pub_key_file_path}") //use this to import local-pub-key
  #public_key = tls_private_key.rsa.public_key_openssh //use this to import tf-pub-key
  tags = {
    key-type = var.key_pair_tag
  }
}
