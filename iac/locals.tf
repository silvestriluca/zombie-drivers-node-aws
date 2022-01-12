locals {
  global_tags = {
    account_id = data.aws_caller_identity.current.account_id
  }
  deploy_stage_map = {
    default = "dev"
    prod    = "prod"
  }
  deploy_stage = local.deploy_stage_map[terraform.workspace]
}
