################## SSM PARAMETER STORE (ONLINE ON/OFF SWITCH) ##################

resource "aws_ssm_parameter" "online_switch" {
  name        = "/${var.app_name_prefix}/${terraform.workspace}/online-switch-${local.deploy_stage}"
  description = "True to instruct Terraform to deploy ${var.app_name_verbose} online - ${local.deploy_stage} stage"
  type        = "SecureString"
  value       = "false"
  tags        = local.global_tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
