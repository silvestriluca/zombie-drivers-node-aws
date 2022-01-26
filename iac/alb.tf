################## ALB ##################
resource "aws_lb" "drivers_alb" {
  count              = aws_ssm_parameter.online_switch.value == "true" ? 1 : 0
  name               = "drivers-alb-${local.deploy_stage}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]

  enable_deletion_protection = false
  enable_http2               = true

  access_logs {
    bucket  = aws_s3_bucket.alb_access_logs_bucket.bucket
    prefix  = "drivers-alb-${local.deploy_stage}"
    enabled = true
  }

  tags = local.global_tags
}

resource "aws_lb_listener" "drivers_alb_http" {
  count             = aws_ssm_parameter.online_switch.value == "true" ? 1 : 0
  load_balancer_arn = aws_lb.drivers_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.global_tags
}


resource "aws_lb_listener" "drivers_alb_https" {
  count             = aws_ssm_parameter.online_switch.value == "true" ? 1 : 0
  load_balancer_arn = aws_lb.drivers_alb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.drivers_cluster.arn
  }
}

resource "aws_lb_target_group" "drivers_cluster" {
  name        = "drivers-cluster-${local.deploy_stage}-tg"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  tags        = local.global_tags
}

################## S3 (ALB Access logs) ##################

resource "aws_s3_bucket" "alb_access_logs_bucket" {
  bucket_prefix = "${var.app_name_prefix}-alb-logs-${local.deploy_stage}"
  acl           = "private"
  force_destroy = true
  # Uses aws/s3 KMS key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
  tags = local.global_tags
}

resource "aws_s3_bucket_public_access_block" "alb_access_logs_bucket" {
  bucket                  = aws_s3_bucket.alb_access_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_access_logs_bucket_policy" {
  bucket = aws_s3_bucket.alb_access_logs_bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.elb_account_id[var.aws_region]}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.alb_access_logs_bucket.arn}/drivers-alb-${local.deploy_stage}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource":  "${aws_s3_bucket.alb_access_logs_bucket.arn}/drivers-alb-${local.deploy_stage}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.alb_access_logs_bucket.arn}"
    }
  ]
}
EOF
}

################## ALB SECURITY GROUPS & RULES ##################

resource "aws_security_group" "alb" {
  name                   = "drivers-alb-${local.deploy_stage}-SG"
  description            = "${var.app_name_verbose} - ALB Security group"
  vpc_id                 = aws_vpc.app_vpc.id
  revoke_rules_on_delete = true
  tags                   = local.global_tags
}

resource "aws_security_group_rule" "alb_in_http" {
  description       = "HTTP IN"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_in_https" {
  description       = "HTTPS IN"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_in_ecs_gateway" {
  description              = "ECS2ALB Gateway IN"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_gateway_service.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_out_ecs_gateway" {
  description              = "ALB2ECS Gateway OUT"
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_gateway_service.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_out_all" {
  description       = "ALB All OUT"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb.id
}
