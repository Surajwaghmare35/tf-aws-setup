##-----------------------------------------CREATE AN IAM ROLE---------------------------------------

# Creating iam role
resource "aws_iam_role" "cwa" {
  name = var.iam_role
  #assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json # (not shown)
  force_detach_policies = true //default is "false"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    "Name" = "EC2-CWA-Server-Policy1"
  }
  inline_policy {
    name   = var.iam_role_inline_server_policy
    policy = data.aws_iam_policy.cwa_server.policy
  }
  inline_policy {
    name = var.iam_role_inline_logRetention_policy
    #policy = aws_iam_user_policy.cwa_logRetention.policy
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:PutRetentionPolicy",
            "Resource": "*"
        }
    ]
}
EOF
  }
  #managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  description = var.iam_role_description
}

# Manually create Instance profile & attach to IAM-role
resource "aws_iam_instance_profile" "cwa" {
  name = var.iam_instance_profile
  role = aws_iam_role.cwa.name
}
