locals {
  global_tags = {
    account_id = data.aws_caller_identity.current.account_id
  }
  deploy_stage = var.workspace_stage_map[terraform.workspace]
}
