locals {
  name_prefix = "${var.name}-rabbitmq"
}

resource "aws_security_group" "rabbitmq" {
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

  user {
    username = var.admin_username
    password = random_password.password.result
  }

  publicly_accessible        = false
  auto_minor_version_upgrade = true
  deployment_mode            = var.multi_az ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"

  logs {
    general = true
  }

  security_groups = [
    aws_security_group.rabbitmq.id
  ]

  subnet_ids = var.subnet_ids
  tags = merge(var.tags, {
    Name = local.name_prefix
  })
}
