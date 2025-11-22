output "shared_node_sg" {
  value = aws_security_group.shared_node.id
}

output "controlplane_sg" {
  value = aws_security_group.controlplane.id
}