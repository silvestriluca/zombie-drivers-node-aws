locals {
  deploy_stage = var.workspace_stage_map[terraform.workspace]
  elb_account_id = {
    us-east-1      = 127311923021
    us-east-2      = 033677994240
    us-west-1      = 027434742980
    us-west-2      = 797873946194
    af-south-1     = 098369216593
    ca-central-1   = 985666609251
    eu-central-1   = 054676820928
    eu-west-1      = 156460612806
    eu-west-2      = 652711504416
    eu-south-1     = 635631232127
    eu-west-3      = 009996457667
    eu-north-1     = 897822967062
    ap-east-1      = 754344448648
    ap-northeast-1 = 582318560864
    ap-northeast-2 = 600734575887
    ap-northeast-3 = 383597477331
    ap-southeast-1 = 114774131450
    ap-southeast-2 = 783225319266
    ap-southeast-3 = 589379963580
    ap-south-1     = 718504428378
    me-south-1     = 076674570225
    sa-east-1      = 507241528517
    us-gov-west-1  = 048591011584
    us-gov-east-1  = 190560391635
    cn-north-1     = 638102146993
    cn-northwest-1 = 037604701340
  }
  global_tags = {
    account_id = data.aws_caller_identity.current.account_id
  }
  go_online = lower(aws_ssm_parameter.online_switch.value) == "true" && lower(aws_ssm_parameter.dns_public_zone.value != "example.com")
}
