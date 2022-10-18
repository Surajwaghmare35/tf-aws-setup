#----------------------------------------CREATE AN IAM USER----------------------------------------

## Create IAM User with gui/cli access with inline-policy

#NOTE: If policies are attached to the user via the 'aws_iam_policy_attachment resource' and you are modifying the 'user name' or 'path', the 'force_destroy' argument must be set to 'true' and applied before attempting the operation 'otherwise' you will encounter a 'DeleteConflict error'. The 'aws_iam_user_policy_attachment resource' (recommended) does not have this requirement.

resource "aws_iam_user" "client_s3_user" {
  name          = "${var.client}-s3-user"
  path          = "/"
  force_destroy = true //default is "false"

  tags = {
    name = "${var.client}-s3-user"
  }
}
output "iam_user" {
  value = aws_iam_user.client_s3_user.name
}

# Generate access_key to allow cli access
resource "aws_iam_access_key" "client_s3_key" {
  user   = aws_iam_user.client_s3_user.name
  status = "Active"
}

output "access_key" {
  value = aws_iam_access_key.client_s3_key.id
}
output "secret_key" {
  value = aws_iam_access_key.client_s3_key.secret
}

## Allow console-management-access //make'#'to allow only CLI
#resource "aws_iam_user_login_profile" "client_s3_user" {
#  user = aws_iam_user.client_s3_user.name
#  #pgp_key = "keybase:some_person_that_exists"
#  password_reset_required = false //<--default, if "true" User create new password at next signIN
#}

resource "aws_iam_policy" "client_s3_policy" {
  name   = "${var.client}-s3-policy"
  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow${upper(var.client)}s3Access",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.client}-lambda",
                "arn:aws:s3:::${var.client}-company-logos",
                "arn:aws:s3:::${var.client}-cms",
                "arn:aws:s3:::${var.client}-resource-repository",
                "arn:aws:s3:::${var.client}-document-repository",
                "arn:aws:s3:::${var.client}-email-attachments"
            ]
        }
    ]
}
EOF
  tags = {
    "Name" = "${var.client}-s3-policy"
  }
}

resource "aws_iam_user_policy_attachment" "client_s3_policy_attach" {
  user       = aws_iam_user.client_s3_user.name
  policy_arn = aws_iam_policy.client_s3_policy.arn
}

# resource "aws_iam_user_policy" "client_s3_policy" {
#   name   = "${var.client}-s3-policy"
#   user   = aws_iam_user.client_s3_user.name
#   policy = aws_iam_policy.client_s3_policy.policy
# }

# data "aws_iam_role" "CWA_S3_Full_Access" {
#   name = "s3-cloudwatch-Full-access"
# }
# output "CWA_S3_Full_Access" {
#   value = data.aws_iam_role.CWA_S3_Full_Access
# }
