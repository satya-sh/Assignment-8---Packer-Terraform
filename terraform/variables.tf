# AWS Region
variable "region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

# Project Naming
variable "project_name" {
  description = "Name of the project - used in resource naming and tags"
  type        = string
  default     = "bastion-deployment"
}

variable "environment" {
  description = "Environment name (dev, staging, prod, etc.)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

# VPC Configuration
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.public_subnets) > 0
    error_message = "At least one public subnet is required."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  validation {
    condition     = length(var.private_subnets) > 0
    error_message = "At least one private subnet is required."
  }
}

# Access Configuration
variable "my_ip" {
  description = "Your IP address for SSH access (CIDR format, e.g., 12.34.56.78/32)"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.my_ip)) && endswith(var.my_ip, "/32")
    error_message = "The my_ip variable must be a valid IP address in CIDR notation with /32 suffix."
  }
}

variable "key_name" {
  description = "SSH key pair name to use for the instances"
  type        = string
  default     = null
}

# AMI Configuration
variable "custom_ami_id" {
  description = "The custom AMI ID created using Packer"
  type        = string
  validation {
    condition     = can(regex("^ami-[a-z0-9]{17}$", var.custom_ami_id))
    error_message = "The AMI ID must be a valid AWS AMI ID (ami-xxxxxxxxxxxxxxxxx)."
  }
}

# Bastion Configuration
variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "bastion_volume_size" {
  description = "Size of the bastion host root volume in GB"
  type        = number
  default     = 8
  validation {
    condition     = var.bastion_volume_size >= 8
    error_message = "Bastion volume size must be at least 8 GB."
  }
}

# Private Instances Configuration
variable "private_instance_type" {
  description = "Instance type for private instances"
  type        = string
  default     = "t2.micro"
}

variable "private_volume_size" {
  description = "Size of the private instances root volume in GB"
  type        = number
  default     = 8
  validation {
    condition     = var.private_volume_size >= 8
    error_message = "Private instance volume size must be at least 8 GB."
  }
}

variable "num_private_instances" {
  description = "Number of private EC2 instances to create"
  type        = number
  default     = 6
  validation {
    condition     = var.num_private_instances >= 1 && var.num_private_instances <= 20
    error_message = "Number of private instances must be between 1 and 20."
  }
}

# Additional Configuration
variable "enable_monitoring" {
  description = "Enable detailed monitoring for instances"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags to add to all resources"
  type        = map(string)
  default     = {}
}