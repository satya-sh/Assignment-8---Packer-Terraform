# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

# Bastion host outputs
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.bastion.public_ip}"
}

# Private instance outputs
output "private_instance_ips" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.private_instances[*].private_ip
}

output "private_instance_ids" {
  description = "Instance IDs of the private instances"
  value       = aws_instance.private_instances[*].id
}

output "private_ssh_commands" {
  description = "SSH commands to connect to private instances through the bastion"
  value       = [for ip in aws_instance.private_instances[*].private_ip : 
                "ssh -i ~/.ssh/id_rsa -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${ip}"]
}

# Connection information
output "connection_instructions" {
  description = "Instructions for connecting to the instances"
  value       = <<-EOT
    # Connection Instructions
    
    ## Connect to bastion host:
    ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.bastion.public_ip}
    
    ## Connect to private instances through bastion:
    ${join("\n", [for i, ip in aws_instance.private_instances[*].private_ip : 
    "# Private Instance ${i+1}\nssh -i ~/.ssh/id_rsa -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${ip}"])}
  EOT
}