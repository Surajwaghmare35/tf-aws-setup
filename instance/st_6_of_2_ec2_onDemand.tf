# ##------------------------------------CREATE AN EC2 INSTANCE----------------------------------------

# ##-------------------To Create On-Demand Instance Follow below one:

# resource "aws_instance" "prod" {
#   ami = data.aws_ami.ubuntu.image_id //auto-assign (recommended) //hardCoded not-recommended

#   instance_type = var.instance_type //hardCoded (recommended)
#   tags = {
#     Name = var.onDemand_I_name_tag // name of instance
#   }

#   subnet_id = aws_subnet.public.id //Assign subnet_ID only when vpc!=default

#   #If you are creating Instances in a VPC, use vpc_security_group_ids instead.
#   vpc_security_group_ids = ["${aws_security_group.tf_sg1.id}"]

#   associate_public_ip_address = true

#   private_dns_name_options {
#     enable_resource_name_dns_a_record    = true
#     enable_resource_name_dns_aaaa_record = false
#     hostname_type                        = "ip-name"
#   }

#   capacity_reservation_specification {
#     capacity_reservation_preference = "open" //default -->alternative=none
#   }

#   instance_initiated_shutdown_behavior = "stop" //default alternative=terminate
#   hibernation                          = false  //default
#   disable_api_stop                     = false  //If "true", enables Instance Stop Protection.
#   disable_api_termination              = false  //If "true", enables Instance Termination Protection.

#   iam_instance_profile = aws_iam_instance_profile.cwa.name

#   monitoring = false //if "true" will detailed monitor

#   tenancy = "default"

#   credit_specification {
#     cpu_credits = "standard" //default for t2-instance-type, unlimited for t3>=
#   }

#   ## Auto-assigning of ENI-card (with-publicIP) to selected subnet is taken-care by AWS

#   metadata_options {
#     http_endpoint               = "enabled"  //default
#     http_tokens                 = "optional" //default -->alternative=required
#     http_put_response_hop_limit = 1          //default
#     instance_metadata_tags      = "disabled" //default
#   }

#   #user_data = filebase64("${path.module}/example.sh")
#   #user_data = filebase64(pathexpand("${var.user_data_file_path}"))

#   key_name = aws_key_pair.tf_key1.key_name

#   root_block_device {
#     volume_size           = var.root_volume_size
#     volume_type           = var.root_volume_type
#     delete_on_termination = true
#     encrypted             = false
#   }
# }

# # Create An Elastic-IP
# resource "aws_eip" "EIP" {
#   public_ipv4_pool = "amazon"
#   vpc              = true
#   #instance         = aws_instance.prod.id
#   tags = {
#     Name = var.eip_tag
#   }
# }
# output "public_EIP" {
#   value = aws_eip.EIP.public_ip
# }

# # Note: this works only on running resource to attach EIP
# when instance is in running state make '!#' & re-run this code at last
# resource "aws_eip_association" "eip_assoc" { //make'#' if not use eip-for-ec2
#   instance_id         = aws_instance.prod.id
#   allocation_id       = aws_eip.EIP.id
#   allow_reassociation = true //make '#' this resource to disassociate Eip with Ec2
# }
