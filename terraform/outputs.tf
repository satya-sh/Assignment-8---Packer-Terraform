output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host (Ansible Controller)"
  value       = aws_instance.bastion.public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.private_instances[*].private_ip
}