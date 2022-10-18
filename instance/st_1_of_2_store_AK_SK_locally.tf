#-----------------------------Store AK,SK locally in json-file--------------------------------------

locals {
  credentials = {
    "User name" = var.iam_user
    #"Password"           = "${aws_iam_user_login_profile.cwa.password}" //make'#'to allow only CLI
    "region"             = "${var.region}"
    "Access Key ID"      = "${aws_iam_access_key.cwa.id}"
    "Secret Access Key"  = "${aws_iam_access_key.cwa.secret}"
    "Console login link" = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console" //default to 'A/c'
  }
}

resource "local_file" "outputdata" {
  content = jsonencode(local.credentials)
  #filename        = "${path.modsule}/${aws_iam_user.cwa.name}.json"
  filename        = pathexpand("${var.path_to_store_ak_sk}/${var.iam_user}.json")
  file_permission = "0664" //default 0777
}
