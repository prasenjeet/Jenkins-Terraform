output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "Public Elastic IP (empty if not enabled)"
  value       = var.associate_public_ip ? aws_eip.this[0].public_ip : null
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}
