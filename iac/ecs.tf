################## IAM POLICIES/ROLES (for ECS) ##################

data "aws_iam_policy" "managed_ecs_task_execution_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name_prefix = "ecs-task-execution-role-${var.app_name_prefix}-"
  description = "Role for ${var.app_name_verbose} ECS Task Execution (agents permissions)"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(local.global_tags, { stage = local.deploy_stage })
}

resource "aws_iam_role_policy_attachment" "managed_ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.managed_ecs_task_execution_policy.arn
}

resource "aws_iam_role" "task_gateway_service_role" {
  name_prefix = "ecs-task-gateway-service-role-${var.app_name_prefix}-"
  description = "Role for ${var.app_name_verbose} - gateway service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(local.global_tags, { stage = local.deploy_stage })
}

resource "aws_iam_role_policy" "task_gateway_service_policy" {
  name_prefix = "task-gateway-service-policy-${var.app_name_prefix}-"
  role        = aws_iam_role.task_gateway_service_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KmsPermissions",
      "Effect": "Allow",
      "Action": [
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*"
        ],
      "Resource": [
          "${data.aws_kms_alias.sns.target_key_arn}"
      ]
    },
    {
      "Sid": "SnsPermissions",
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
          "${aws_sns_topic.drivers_updates.arn}"
      ]
    }     
  ]
}
EOF
}

####### KMS #######

data "aws_kms_alias" "sns" {
  name = "alias/aws/sns"
}

################## CLOUDWATCH ##################

resource "aws_cloudwatch_log_group" "gateway_service" {
  name              = "/aws/ecs/${var.app_name_prefix}/${local.deploy_stage}/gateway-service"
  retention_in_days = 60
  tags              = merge(local.global_tags, { stage = local.deploy_stage })
}

####### ECS #######

resource "aws_ecs_account_setting_default" "cluster_account" {
  name  = "containerInsights"
  value = "enabled"
}

resource "aws_ecs_cluster" "microservices" {
  name               = "drivers-cluster-${local.deploy_stage}"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.global_tags, { stage = local.deploy_stage })
}

resource "aws_ecs_task_definition" "gateway" {
  family                   = "${var.app_name_prefix}-gateway-service"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task_gateway_service_role.arn
  container_definitions = jsonencode([
    {
      name              = "gateway"
      image             = "${aws_ecr_repository.gateway_service.repository_url}:latest"
      cpu               = 512
      memory            = 1024
      memoryReservation = 512
      essential         = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 60
        timeout     = 20
        retries     = 3
        startPeriod = 120
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/${var.app_name_prefix}/${local.deploy_stage}/gateway-service"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs-gateway-service-"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = merge(local.global_tags, { stage = local.deploy_stage, microservice = "${var.app_name_prefix}-gateway-service" })
}


