
################## REDIS SECURITY GROUPS & RULES ##################

resource "aws_security_group" "redis" {
  name                   = "Redis-${local.deploy_stage}-SG"
  description            = "Redis security group (${local.deploy_stage})"
  vpc_id                 = aws_vpc.app_vpc.id
  revoke_rules_on_delete = true
  tags                   = local.global_tags
}

resource "aws_security_group_rule" "redis_in" {
  description       = "Redis IN"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_out_all" {
  description       = "Redis ALL OUT"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.redis.id
}

################## REDIS ##################

# TODO

resource "aws_elasticache_subnet_group" "redis" {
  name       = "driver-location-subnet"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
}

resource "aws_elasticache_replication_group" "example" {
  count                         = 0
  automatic_failover_enabled    = true
  availability_zones            = [var.az1, var.az2, var.az3]
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  multi_az_enabled              = true
  replication_group_id          = "driver-location"
  replication_group_description = "driver-location Redis replica group"
  node_type                     = "cache.t3.micro"
  number_cache_clusters         = 3
  apply_immediately             = true
  at_rest_encryption_enabled    = true
  engine                        = "redis"
  engine_version                = "6.x"
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  security_group_ids            = [aws_security_group.redis.id]
  maintenance_window            = "sun:05:00-sun:09:00"
  tags                          = local.global_tags
}
