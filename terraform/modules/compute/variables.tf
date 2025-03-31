variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type for private instances"
  type        = string
}

variable "num_private_instances" {
  description = "Number of private EC2 instances"
  type        = number
}

variable "ubuntu_ami_id" {
  description = "AMI ID for Ubuntu instances"
  type        = string
}

variable "amazon_ami_id" {
  description = "AMI ID for Amazon Linux instances"
  type        = string
}

variable "bastion_sg_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "private_sg_id" {
  description = "ID of the private instances security group"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for the bastion host"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the key pair to use for instances"
  type        = string
}