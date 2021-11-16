####### SNS #######
resource "aws_sns_topic" "drivers_updates" {
  name              = "drivers-updates"
  kms_master_key_id = "alias/aws/sns"
  tags = local.global_tags
}

####### SQS #######
resource "aws_sqs_queue" "drivers_updates_queue" {
  name                              = "drivers-updates"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  message_retention_seconds = 86400
  tags = local.global_tags
}

####### SQS SUBSCRIPTION TO SNS #######
resource "aws_sns_topic_subscription" "driver_updates_sqs_target" {
  topic_arn = aws_sns_topic.drivers_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.drivers_updates_queue.arn
}

####### SQS POLICY #######
# To accept messages from SNS

resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url = aws_sqs_queue.drivers_updates_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "Allow_SNS_drivers_updates",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.drivers_updates_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.drivers_updates.arn}"
        }
      }
    }
  ]
}
POLICY
}
