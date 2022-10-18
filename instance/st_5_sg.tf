#------------------------Creating an SG with ingress-Egress rule------------------------------------

resource "aws_security_group" "tf_sg1" {
  name        = var.sg_name
  description = var.sg_description //default is "Managed by Terraform"
  vpc_id      = aws_vpc.vpc.id     //assign new vpc_id onlyIF vpc != default
  #if we not mentioned vpc id,its create an sg in default vpc
  #vpc_id = "vpc-0f69e8cb579ca335e" //main vpc

  #creating dynamic-block for "ingress" & "egress" rule
  dynamic "ingress" {
    for_each = [22,80]
    iterator = port
    content {
      #description = ""
      from_port = port.value
      to_port   = port.value
      protocol  = "tcp"
      #cidr_blocks = ["0.0.0.0/0"]
      cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] //chomp() remove'\n' at EOstring
      #cidr_blocks = [aws_vpc.vpc.cidr_block]
    }
  }
  dynamic "egress" {
    for_each = [0]
    iterator = port
    content {
      #description = ""
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1" //all
      cidr_blocks = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = ["::/0"] //optionl ipv6
    }
  }
  tags = {
    Name = var.sg_tag
  }
}

# Assigning tag to Default-SG by keeping default ingress-Egress rule

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.vpc.id

  #creating dynamic-block for "ingress" & "egress" rule
  dynamic "ingress" {
    for_each = [0]
    iterator = port
    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "-1"
      self      = true //adding sg itselt as a source in inbound
    }
  }
  dynamic "egress" {
    for_each = [0]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1" //all
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = var.default_sg_tag
  }
}
