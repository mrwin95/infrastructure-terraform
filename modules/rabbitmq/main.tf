locals {
  name_prefix = "${var.name}-rabbitmq"
}

resource "aws_security_group" "rabbitmq" {
  count = var.publicly_accessible ? 0 : 1

  name        = "${local.name_prefix}-sg"
  description = "Security group for RabbitMQ broker"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow AMQP 5671 TLS"
    from_port       = 5671
    to_port         = 5671
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidrs
    security_groups = var.allowed_security_groups
  }

  ingress {
    description     = "Allow management console 15671 TLS"
    from_port       = 15671
    to_port         = 15671
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidrs
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-sg"
  })
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "admin" {
  name = "${local.name_prefix}-admin"
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id
  secret_string = jsonencode({
    username = var.admin_username
    password = random_password.password.result
  })
}

resource "aws_mq_broker" "this" {
  broker_name        = local.name_prefix
  engine_type        = "RabbitMQ"
  engine_version     = var.engine_version
  host_instance_type = var.instance_type

  publicly_accessible = var.publicly_accessible
  user {
    username = var.admin_username
    password = random_password.password.result
  }

  auto_minor_version_upgrade = true
  deployment_mode            = var.multi_az ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"

  logs {
    general = true
  }

  security_groups = var.publicly_accessible ? null : [aws_security_group.rabbitmq[0].id]

  subnet_ids = var.publicly_accessible ? null : var.subnet_ids
  tags = merge(var.tags, {
    Name = local.name_prefix
  })
}
