####### SNS #######
resource "aws_sns_topic" "drivers_updates" {
  name              = "drivers-updates"
  #kms_master_key_id = "alias/aws/sns"
  tags = local.global_tags
}

####### SQS #######
resource "aws_sqs_queue" "drivers_updates_queue" {
  name                              = "drivers-updates"
  #kms_master_key_id                 = "alias/aws/sqs"
  #kms_data_key_reuse_period_seconds = 300
  message_retention_seconds = 86400
  tags = local.global_tags
}

####### SQS SUBSCRIPTION TO SNS #######
resource "aws_sns_topic_subscription" "driver_updates_sqs_target" {
  topic_arn = aws_sns_topic.drivers_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.drivers_updates_queue.arn
}
