# provider "aws" {
#   region = "us-east-1"
#   #version = "~> 2.0"
# }
# variable "client" {}
# variable "domain" {}
# variable "zone-id" {}

# resource "aws_acm_certificate" "cert1_s3" {
#   domain_name       = "resource.${var.client}.${var.domain}"
#   validation_method = "DNS"
# }
# resource "aws_acm_certificate" "cert2_s3" {
#   domain_name       = "docs.${var.client}.${var.domain}"
#   validation_method = "DNS"
# }
# resource "aws_acm_certificate" "cert3_s3" {
#   domain_name       = "attachments.${var.client}.${var.domain}"
#   validation_method = "DNS"
# }

# resource "aws_route53_record" "cert_validation_s31" {
#   name    = aws_acm_certificate.cert1_s3.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.cert1_s3.domain_validation_options.0.resource_record_type
#   zone_id = var.zone-id
#   records = ["${aws_acm_certificate.cert1_s3.domain_validation_options.0.resource_record_value}"]
#   ttl     = 60
# }
# resource "aws_route53_record" "cert_validation_s32" {
#   name    = aws_acm_certificate.cert2_s3.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.cert2_s3.domain_validation_options.0.resource_record_type
#   zone_id = var.zone-id
#   records = ["${aws_acm_certificate.cert2_s3.domain_validation_options.0.resource_record_value}"]
#   ttl     = 60
# }
# resource "aws_route53_record" "cert_validation_s33" {
#   name    = aws_acm_certificate.cert3_s3.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.cert3_s3.domain_validation_options.0.resource_record_type
#   zone_id = var.zone-id
#   records = ["${aws_acm_certificate.cert3_s3.domain_validation_options.0.resource_record_value}"]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "cert1_s3" {
#   certificate_arn         = aws_acm_certificate.cert1_s3.arn
#   validation_record_fqdns = ["${aws_route53_record.cert_validation_s31.fqdn}"]
# }
# resource "aws_acm_certificate_validation" "cert2_s3" {
#   certificate_arn         = aws_acm_certificate.cert2_s3.arn
#   validation_record_fqdns = ["${aws_route53_record.cert_validation_s32.fqdn}"]
# }
# resource "aws_acm_certificate_validation" "cert3_s3" {
#   certificate_arn         = aws_acm_certificate.cert3_s3.arn
#   validation_record_fqdns = ["${aws_route53_record.cert_validation_s33.fqdn}"]
# }
# output "cert_arn_s31" {
#   value = aws_acm_certificate.cert1_s3.arn
# }
# output "cert_arn_s32" {
#   value = aws_acm_certificate.cert2_s3.arn
# }
# output "cert_arn_s33" {
#   value = aws_acm_certificate.cert3_s3.arn
# }
