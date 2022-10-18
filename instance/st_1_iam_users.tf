#----------------------------------------CREATE AN IAM USER----------------------------------------

## Create IAM User with gui/cli access with inline-policy

#NOTE: If policies are attached to the user via the 'aws_iam_policy_attachment resource' and you are modifying the 'user name' or 'path', the 'force_destroy' argument must be set to 'true' and applied before attempting the operation 'otherwise' you will encounter a 'DeleteConflict error'. The 'aws_iam_user_policy_attachment resource' (recommended) does not have this requirement.

resource "aws_iam_user" "cwa" {
  name          = var.iam_user
  path          = "/"
  force_destroy = true //default is "false"

  tags = {
    name = var.iam_user_tag
  }
}

# Generate access_key to allow cli access
resource "aws_iam_access_key" "cwa" {
  user   = aws_iam_user.cwa.name
  status = "Active"
}

## Allow console-management-access //make'#'to allow only CLI
#resource "aws_iam_user_login_profile" "cwa" {
#  user = var.iam_user
#  #pgp_key = "keybase:some_person_that_exists"
#  password_reset_required = false //<--default, if "true" User create new password at next signIN
#}

resource "aws_iam_user_policy" "cwa_server" {
  name   = var.iam_user_server_policy
  user   = aws_iam_user.cwa.name
  policy = data.aws_iam_policy.cwa_server.policy //attaching aws-managed cwa-server-policy
}

# Create & attach onPremise-CWA-logRetention policy
resource "aws_iam_user_policy" "cwa_logRetention" {
  name   = var.iam_user_logRetention_policy
  user   = aws_iam_user.cwa.name
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
