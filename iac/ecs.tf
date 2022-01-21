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

  tags = local.global_tags
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

  tags = local.global_tags
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

################## KMS ##################

data "aws_kms_alias" "sns" {
  name = "alias/aws/sns"
}

################## CLOUDWATCH ##################

resource "aws_cloudwatch_log_group" "gateway_service" {
  name              = "/aws/ecs/${var.app_name_prefix}/${local.deploy_stage}/gateway-service"
  retention_in_days = 60
  tags              = local.global_tags
}

################## SERVICE DISCOVERY ##################

resource "aws_service_discovery_private_dns_namespace" "zombie_services" {
  name        = "zdrivers-${local.deploy_stage}.local"
  description = "Zombie drivers services - ${local.deploy_stage}"
  vpc         = aws_vpc.app_vpc.id
  tags        = local.global_tags
}

resource "aws_service_discovery_service" "gateway_service" {
  name          = "gateway"
  description   = "Gateway service for Zombie Driver - ${local.deploy_stage}"
  force_destroy = true
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.zombie_services.id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 3
  }
  tags = local.global_tags
}

################## ECS SECURITY GROUPS & RULES ##################

resource "aws_security_group" "ecs_gateway_service" {
  name                   = "ECS-gateway-service-${local.deploy_stage}-SG"
  description            = "Gateway service security group (${local.deploy_stage})"
  vpc_id                 = aws_vpc.app_vpc.id
  revoke_rules_on_delete = true
  tags                   = local.global_tags
}

resource "aws_security_group_rule" "ecs_gateway_in" {
  description              = "ALB2ECS Gateway IN"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_gateway_service.id
}

resource "aws_security_group_rule" "ecs_gateway_out" {
  description              = "ECS2ALB Gateway OUT"
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_gateway_service.id
}

################## ECS ##################

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

  tags = local.global_tags
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
  tags = merge(local.global_tags, { microservice = "${var.app_name_prefix}-gateway-service" })
}

resource "aws_ecs_service" "gateway" {
  name                 = "gateway-service-${local.deploy_stage}"
  cluster              = aws_ecs_cluster.microservices.id
  task_definition      = aws_ecs_task_definition.gateway.arn
  desired_count        = 0
  force_new_deployment = true

  deployment_controller {
    type = "ECS"
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  /* Placement strategies are not supported in Fargate
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
*/

  network_configuration {
    subnets = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.public_subnet_3.id
    ]
    security_groups  = [aws_security_group.ecs_gateway_service.id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.gateway_service.arn

  }

  dynamic "load_balancer" {
    for_each = aws_lb.drivers_alb
    content {
      target_group_arn = aws_lb_target_group.drivers_cluster.arn
      container_name   = "gateway"
      container_port   = 3000
    }
  }

  tags = local.global_tags
}
