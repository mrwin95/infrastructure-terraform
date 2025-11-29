output "broker_id" {
  value = aws_mq_broker.this.id
}

output "amqp_endpoint" {
  value = aws_mq_broker.this.instances[0].endpoints[0]
}

output "management_console" {
  value = aws_mq_broker.this.instances[0].console_url
}

output "security_group_id" {
  value = aws_security_group.rabbitmq.id
}

output "admin_secret_arn" {
  value = aws_secretsmanager_secret.admin.arn
}
