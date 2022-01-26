################## SSM PARAMETER STORE (ALB ON/OFF SWITCH) ##################

resource "aws_ssm_parameter" "online_switch" {
  name  = "/${var.app_name_prefix}/${terraform.workspace}/online-switch-${local.deploy_stage}"
  type  = "SecureString"
  value = "false"
  tags  = local.global_tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
