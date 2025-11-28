resource "aws_security_group" "shared_node" {
  name        = var.shared_node_security_group
  vpc_id      = var.vpc_id
  description = "Test Node-to-Node communication"

  tags = {
    Name = "test-shared-node-sg"
  }
}

resource "aws_security_group" "controlplane" {
  name        = var.controlplane_security_group
  vpc_id      = var.vpc_id
  description = "Test Control plane communication"

  tags = {
    Name = "test-control-plane-sg"
  }
}

# ingress

resource "aws_security_group_rule" "controlplane_to_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.shared_node.id
  source_security_group_id = aws_security_group.controlplane.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
}

resource "aws_security_group_rule" "nodes_to_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.shared_node.id
  source_security_group_id = aws_security_group.shared_node.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
}

resource "aws_security_group_rule" "nodes_to_controlplane" {
  type                     = "ingress"
  security_group_id        = aws_security_group.controlplane.id
  source_security_group_id = aws_security_group.shared_node.id
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 65535
}
