################## SSM PARAMETER STORE (DNS ZONE/DOMAIN) ##################

resource "aws_ssm_parameter" "dns_public_zone" {
  name        = "/${var.app_name_prefix}/${terraform.workspace}/dns-zone-${local.deploy_stage}"
  description = "DNS Public Zone to deploy ${var.app_name_verbose} - ${local.deploy_stage} stage"
  type        = "SecureString"
  value       = "example.com"
  tags        = local.global_tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "dns_app_host" {
  name        = "/${var.app_name_prefix}/${terraform.workspace}/dns-app-host-${local.deploy_stage}"
  description = "Hostname to deploy ${var.app_name_verbose} - ${local.deploy_stage} stage"
  type        = "SecureString"
  value       = "${local.deploy_stage}.zdriver"
  tags        = local.global_tags
}

################## DNS ZONE ##################

data "aws_route53_zone" "dns_public_zone" {
  count = aws_ssm_parameter.dns_public_zone.value == "example.com" ? 0 : 1
  name  = aws_ssm_parameter.dns_public_zone.value
}

