####### ECR #######
resource "aws_ecr_repository" "gateway_service" {
  name                 = "zdriv-service-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}

resource "aws_ecr_repository" "driver_location_service" {
  name                 = "zdriv-service-driver-location"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}

resource "aws_ecr_repository" "zombie_detector_service" {
  name                 = "zdriv-service-zombie-detector"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}

################## ECR SECURITY GROUPS & RULES ##################

resource "aws_security_group" "ecr_vpc_endpoints" {
  name                   = "ECR-vpc-endpoint-${local.deploy_stage}-SG"
  description            = "ECR private endpoint SG (${local.deploy_stage})"
  vpc_id                 = aws_vpc.app_vpc.id
  revoke_rules_on_delete = true
  tags                   = local.global_tags
}

resource "aws_security_group_rule" "ecr_vpc_endpoints_in" {
  description       = "ECR VPC Endpoint IN (VPC LAN)"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ecr_vpc_endpoints.id
}

resource "aws_security_group_rule" "ecr_vpc_endpoints_out" {
  description       = "ECR VPC Endpoint OUT (ALL/Everywhere)"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.ecr_vpc_endpoints.id
}

####### VPC ENDPOINTS #######

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = local.vpc_endpoints_on ? 1 : 0
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoints.id]
  tags                = local.global_tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = local.vpc_endpoints_on ? 1 : 0
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoints.id]
  tags                = local.global_tags
}

resource "aws_vpc_endpoint" "s3_gateway" {
  count             = local.vpc_endpoints_on ? 1 : 0
  vpc_id            = aws_vpc.app_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.app_vpc_rt_pub.id, aws_route_table.app_vpc_rt_pvt.id]
  policy            = <<EOF
{
  "Statement": [
    {
      "Sid": "Access-to-specific-bucket-only",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::prod-${var.aws_region}-starport-layer-bucket/*"]
    }
  ]
}  
EOF
  tags              = local.global_tags
}
