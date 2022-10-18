variable "client" {}

# Fetching canonical_user_id
data "aws_canonical_user_id" "current" {}

output "canonical_user_id" {
  value = data.aws_canonical_user_id.current.id
}

# Creating Private Bucket1
resource "aws_s3_bucket" "client_cms" {
  bucket        = "${var.client}-cms"
  force_destroy = true //default is 'false'
  tags = {
    Name        = "${var.client}-cms"
    Environment = "Dev"
  }
}
output "cms_pri_bucket" {
  value = aws_s3_bucket.client_cms.bucket

}
# resource "aws_s3_bucket_versioning" "cms_version" {
#   bucket = aws_s3_bucket.client_cms.id

#   versioning_configuration {
#     status = "Enabled" //alt: Suspended
#   }
# }

resource "aws_s3_bucket_public_access_block" "cms_access" {
  bucket = aws_s3_bucket.client_cms.id

  block_public_acls       = true //keep 'true' if bucket is private
  ignore_public_acls      = false
  block_public_policy     = true //keep 'true' if bucket is private
  restrict_public_buckets = false
}
//above all default is false

resource "aws_s3_bucket_ownership_controls" "cms_ownership" {
  bucket = aws_s3_bucket.client_cms.id

  rule {
    object_ownership = "ObjectWriter" // alt: BucketOwnerEnforced
  }
}


# Creating Public Bucket2

resource "aws_s3_bucket" "client_logos" {
  bucket        = "${var.client}-company-logos"
  force_destroy = true //default is 'false'
  tags = {
    Name        = "${var.client}-company-logos"
    Environment = "Dev"
  }
}
# resource "aws_s3_bucket_versioning" "client_logos_version" {
#   bucket = aws_s3_bucket.client_logos.id

#   versioning_configuration {
#     status = "Enabled" //alt: Disabled(not-work), Suspended (work)
#   }
# }
resource "aws_s3_bucket_public_access_block" "logos_access" {
  bucket = aws_s3_bucket.client_logos.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
  //above all default is false, keep as it is if conf. bucket as complete-public
}
resource "aws_s3_bucket_ownership_controls" "logos_ownership" {
  bucket = aws_s3_bucket.client_logos.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "logos_acl" {
  bucket = aws_s3_bucket.client_logos.id
  access_control_policy {
    dynamic "grant" {
      for_each = ["FULL_CONTROL"]
      iterator = rule
      content {
        grantee {
          id   = data.aws_canonical_user_id.current.id
          type = "CanonicalUser"
        }
        permission = rule.value //WRITE, FULL_CONTROL
      }
    }
    dynamic "grant" {
      for_each = ["READ_ACP"]
      iterator = rule
      content {
        grantee {
          type = "Group"
          uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
        }
        permission = rule.value //alt: WRITE, FULL_CONTROL
      }
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

# Creating Private Bucket3
resource "aws_s3_bucket" "client_lambda" {
  bucket        = "${var.client}-lambda"
  force_destroy = true //default is 'false'
  tags = {
    Name        = "${var.client}-lambda"
    Environment = "Dev"
  }
}
# resource "aws_s3_bucket_versioning" "lambda_version" {
#   bucket = aws_s3_bucket.client_lambda.id

#   versioning_configuration {
#     status = "Enabled" //alt: Suspended
#   }
# }

resource "aws_s3_bucket_public_access_block" "lambda_access" {
  bucket = aws_s3_bucket.client_lambda.id

  block_public_acls       = true //keep 'true' if bucket is private
  ignore_public_acls      = false
  block_public_policy     = true //keep 'true' if bucket is private
  restrict_public_buckets = false
}
//above all default is false

resource "aws_s3_bucket_ownership_controls" "lambda_ownership" {
  bucket = aws_s3_bucket.client_lambda.id

  rule {
    object_ownership = "ObjectWriter" // alt: BucketOwnerEnforced
  }
}
