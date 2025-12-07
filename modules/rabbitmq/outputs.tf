output "broker_id" {
  value       = aws_mq_broker.this.id
  description = "Amazon MQ RabbitMQ broker ID"
}

output "broker_arn" {
  value       = aws_mq_broker.this.arn
  description = "Amazon MQ RabbitMQ broker ARN"
}

output "endpoints" {
  value       = aws_mq_broker.this.instances[*].endpoints
  description = "RabbitMQ broker endpoints"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security group ID for RabbitMQ broker"
}

output "connection_secret_arn" {
  value       = aws_secretsmanager_secret.connection.arn
  description = "Secrets Manager secret ARN with RabbitMQ connection details"
}
