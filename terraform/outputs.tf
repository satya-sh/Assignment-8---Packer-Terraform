output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host (Ansible Controller)"
  value       = module.compute.bastion_public_ip
}

output "private_instance_ips" {
  description = "Private IPs of the EC2 instances"
  value       = module.compute.private_instance_ips
}

# Additional useful outputs
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnets
}