output "bastion_public_ip" {
  description = "Public IP of the bastion host (Ansible Controller)"
  value       = aws_instance.bastion.public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.private_instances[*].private_ip
}

output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "private_instance_ids" {
  description = "IDs of the private instances"
  value       = aws_instance.private_instances[*].id
}