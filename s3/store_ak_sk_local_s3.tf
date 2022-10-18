variable "region" {}
variable "iam_user" {}
variable "access_key" {}
variable "secret_key" {}
variable "path_to_store_ak_sk" {}
variable "account_id" {}
variable "bucket" {}

# Fetching Aws A/c details as ID
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


#-----------------------------Store AK,SK locally in json-file--------------------------------------

locals {
  credentials = {
    "User name"          = var.iam_user
    "Password"           = null
    "region"             = var.region
    "Access Key ID"      = var.access_key
    "Secret Access Key"  = var.secret_key
    "Console login link" = "https://${var.account_id}.signin.aws.amazon.com/console" //default to 'A/c'
  }
}

resource "local_sensitive_file" "outputdata" {
  content = jsonencode(local.credentials)
  #filename        = "${path.modsule}/${aws_iam_user.client_s3_user.name}.json"
  filename        = pathexpand("${var.path_to_store_ak_sk}/${var.iam_user}.json")
  file_permission = "0664" //default 0777
}

# store ak sk on s3
resource "aws_s3_object" "client_ak_sk" {
  bucket        = var.bucket
  key           = "${var.iam_user}.json"
  source        = local_sensitive_file.outputdata.filename
  acl           = "private"
  storage_class = "STANDARD"
  etag          = md5("${local_sensitive_file.outputdata.content}")
  lifecycle {
    replace_triggered_by = [local_sensitive_file.outputdata.id]
  }
  depends_on = [local_sensitive_file.outputdata]
}
