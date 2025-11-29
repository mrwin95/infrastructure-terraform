
locals {
  engine_version = var.engine_version == "" ? "7.2" : var.engine_version
  name_prefix    = "${var.name}-valkey"
}

# -----------------------------------------------------
# Subnet Group
# -----------------------------------------------------
resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name_prefix}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-subnets"
  })
}

# -----------------------------------------------------
# Security Group
# -----------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-sg"
  description = "SG for Valkey ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Valkey traffic"
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
# Parameter Group
# -----------------------------------------------------
resource "aws_elasticache_parameter_group" "this" {
  name        = "${local.name_prefix}-params"
  family      = var.family
  description = "Parameter group for Valkey ${var.name}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}

# -----------------------------------------------------
# Replication Group (Cluster or Single-Node)
# -----------------------------------------------------
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.name_prefix
  //replication_group_description = "Valkey replication group for ${var.name}"
  engine         = "valkey"
  engine_version = local.engine_version
  port           = var.port

  automatic_failover_enabled = var.multi_az
  multi_az_enabled           = var.multi_az

  # Cluster mode
  num_cache_clusters = var.cluster_mode_enabled ? null : var.node_count

  #   dynamic "cluster_mode" {
  #     for_each = var.cluster_mode_enabled ? [1] : []
  #     content {
  #       num_node_groups         = var.cluster_num_node_groups
  #       replicas_per_node_group = var.cluster_replicas_per_group
  #     }
  #   }

  # Cluster mode enabled (sharding)
  num_node_groups         = var.cluster_mode_enabled ? var.cluster_num_node_groups : null
  replicas_per_node_group = var.cluster_mode_enabled ? var.cluster_replicas_per_group : null

  node_type                  = var.node_type
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [aws_security_group.this.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  maintenance_window       = var.maintenance_window
  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit
  description              = "Cluster group"
  tags = merge(var.tags, {
    Name = local.name_prefix
  })
}
