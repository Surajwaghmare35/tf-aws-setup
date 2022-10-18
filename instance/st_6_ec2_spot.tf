##------------------------------------CREATE AN EC2 INSTANCE-----------------------------------------

##------------------- TO Request a spot instance follow this resource

resource "aws_spot_instance_request" "spot" {
  ami           = data.aws_ami.ubuntu.image_id //auto-assign (recommended) ,hardCoded not-recommended
  instance_type = var.instance_type            //hardCoded (recommended)
  tags = {
    Name = var.spot_instance_id_tag //its applied to Spot Req-ID not Spot-I ID--manually do using console
  }
  spot_price = data.aws_ec2_spot_price.price.spot_price
  #spot_price           = "0.0037" #make it'#' or assign price by checking on aws-console as per AZ  
  spot_type            = "one-time"
  wait_for_fulfillment = true //default "false"

  subnet_id = aws_subnet.public.id //Assign subnet_ID only when vpc!=default

  #If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  vpc_security_group_ids = ["${aws_security_group.tf_sg1.id}"]

  associate_public_ip_address = true

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open" //default -->alternative=none
  }

  instance_initiated_shutdown_behavior = "stop" //default alternative=terminate
  hibernation                          = false  //default
  disable_api_stop                     = false  //If "true", enables Instance Stop Protection.
  disable_api_termination              = false  //If "true", enables Instance Termination Protection.

  iam_instance_profile = aws_iam_instance_profile.cwa.name

  monitoring = false //if "true" will detailed monitor

  tenancy = "default"

  credit_specification {
    cpu_credits = "standard" //default for t2-instance-type, unlimited for t3>=
  }

  ## Auto-assigning of ENI-card (with-publicIP) to selected subnet is taken-care by AWS

  metadata_options {
    http_endpoint               = "enabled"  //default
    http_tokens                 = "optional" //default -->alternative=required
    http_put_response_hop_limit = 1          //default
    instance_metadata_tags      = "disabled" //default
  }

  #user_data = filebase64("${path.module}/example.sh")
  user_data = filebase64(pathexpand("${var.user_data_file_path}"))


  key_name = aws_key_pair.tf_key1.key_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = false
  }
}

## Use only if instance=spot: 'aws_ec2_tag' resource to assign tag to Spot-I-id
resource "aws_ec2_tag" "Spot-I-Name" {
  resource_id = aws_spot_instance_request.spot.spot_instance_id
  key         = "Name"
  value       = var.spot_I_name_tag
}

##-------------------Getting Ec2-publicIP o/p using 'aws_instance' data-source----------------------

output "InstanceIP" {
  value = data.aws_instance.u-ami.public_ip
}

##SPOT-I Details		--------//use when 'instance = spot'--------else make '#'--------
output "Spot-InstanceID" {
  value = aws_spot_instance_request.spot.spot_instance_id
}
output "Spot-Req-ID" {
  value = aws_spot_instance_request.spot.id
}

#Note: about count meta argument
#count         = 0 # if we set this then tf ingnore this resource creation

# # Create An Elastic-IP
# resource "aws_eip" "EIP" {
#   public_ipv4_pool = "amazon"
#   vpc              = true
#   instance         = aws_spot_instance_request.spot.spot_instance_id
#   tags = {
#     Name = var.eip_tag
#   }
#   # timeouts {
#   #   #read   = "2m"
#   #   update = "2m"
#   # }
#   # #depends_on = [aws_spot_instance_request.spot]
# }
# output "public_EIP" {
#   value = aws_eip.EIP.public_ip
# }

# # Note: this works only on running resource to attach EIP
# # when instance is in running state make '!#' & re-run this code at last
# resource "aws_eip_association" "eip_assoc" { //make'#' if not use eip-for-ec2
#   instance_id         = aws_spot_instance_request.spot.spot_instance_id
#   allocation_id       = aws_eip.EIP.id
#   allow_reassociation = true //make '#' this resource to disassociate Eip with Ec2
#   #depends_on          = [aws_eip.EIP]
# }
