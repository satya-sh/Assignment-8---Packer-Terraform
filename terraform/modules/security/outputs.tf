output "bastion_sg_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "private_sg_id" {
  description = "ID of the private instances security group"
  value       = aws_security_group.private.id
}