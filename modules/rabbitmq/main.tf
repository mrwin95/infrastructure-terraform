locals {
  name_prefix = "${var.name}-rabbitmq"
  mq_subnets  = var.deployment_mode == "SINGLE_INSTANCE" ? [var.subnet_ids[0]] : var.subnet_ids
}

# -----------------------------------------------------
# Security Group
# -----------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-sg"
  description = "SG for RabbitMQ ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow RabbitMQ TLS traffic"
    from_port       = var.port
    to_port         = var.port
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

# -----------------------------------------------------
# RabbitMQ Broker (Amazon MQ)
# -----------------------------------------------------
resource "aws_mq_broker" "this" {
  broker_name = local.name_prefix

  engine_type    = "RabbitMQ"
  engine_version = var.engine_version

  host_instance_type  = var.instance_type
  publicly_accessible = false
  deployment_mode     = var.deployment_mode

  subnet_ids      = local.mq_subnets
  security_groups = [aws_security_group.this.id]

  logs {
    general = true
  }

  # Basic auth for RabbitMQ
  user {
    username       = var.admin_username
    password       = var.admin_password
    console_access = true
  }

  auto_minor_version_upgrade = true

  tags = merge(var.tags, {
    Name = local.name_prefix
  })
}

# -----------------------------------------------------
# Secrets Manager: Connection details
# -----------------------------------------------------
resource "aws_secretsmanager_secret" "connection" {
  name = "${local.name_prefix}-connection"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-connection"
  })
}

resource "aws_secretsmanager_secret_version" "connection" {
  secret_id = aws_secretsmanager_secret.connection.id

  secret_string = jsonencode({
    engine   = "rabbitmq"
    protocol = "amqps"
    host     = aws_mq_broker.this.instances[0].endpoints[0]
    port     = var.port
    username = var.admin_username
    password = var.admin_password
    vhost    = var.vhost
    uri      = "amqps://${var.admin_username}:${var.admin_password}@${aws_mq_broker.this.instances[0].endpoints[0]}:${var.port}${var.vhost}"
  })
}

# -----------------------------------------------------
# Pod Identity – attach policy to existing role
# (role is created by your pod_identity module)
# -----------------------------------------------------
resource "aws_iam_role_policy" "pod_identity_rabbitmq" {
  count = var.enable_pod_identity && var.pod_identity_role_name != "" ? 1 : 0

  name = "${local.name_prefix}-secrets-policy"
  role = var.pod_identity_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.connection.arn
      }
    ]
  })
}
