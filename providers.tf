##---------------------------------Provider Configuration--------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1" //(hardCoded-recommended)
  #shared_config_files      = ["/home/suraj/.aws/config"]
  #shared_credentials_files = ["/home/suraj/.aws/credentials"]
  profile = "default"
  #access_key = "xxxxxxxxxx"    //replace xx with AK-valuse     //20-char(string)
  #secret_key = "xxxxxxxxxxxxxxxxxxxx" ///replace xx with SK-valuse     //40-char(string)
}
