################## ACM CERTIFICATE IMPORT ##################

data "aws_acm_certificate" "zombie_driver" {
  count       = aws_ssm_parameter.dns_public_zone.value == "example.com" ? 0 : 1
  domain      = "zdriver.${aws_ssm_parameter.dns_public_zone.value}"
  statuses    = ["ISSUED"]
  most_recent = true
}
