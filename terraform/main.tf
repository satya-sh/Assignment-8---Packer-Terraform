# Provider configuration
provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name                = var.vpc_name
  cidr                = var.vpc_cidr
  azs                 = var.azs
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  
  enable_nat_gateway  = true
  single_nat_gateway  = true
  enable_dns_hostnames = true
  enable_dns_support  = true
  
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

# Security Groups
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host - SSH access from whitelisted IP"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH access from whitelisted IP"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "private" {
  name        = "${var.environment}-private-sg"
  description = "Security group for private instances - SSH access from bastion only"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH access from bastion host"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name        = "${var.environment}-private-sg"
    Environment = var.environment
  }
}

# EC2 Instances
resource "aws_instance" "bastion" {
  ami                         = var.custom_ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  
  key_name                    = var.key_name
  
  root_block_device {
    volume_size = var.bastion_volume_size
    encrypted   = true
  }
  
  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
    Role        = "bastion"
  }
}

resource "aws_instance" "private_instances" {
  count                  = var.num_private_instances
  ami                    = var.custom_ami_id
  instance_type          = var.private_instance_type
  subnet_id              = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  vpc_security_group_ids = [aws_security_group.private.id]
  
  key_name               = var.key_name
  
  root_block_device {
    volume_size = var.private_volume_size
    encrypted   = true
  }
  
  tags = {
    Name        = "${var.environment}-private-instance-${count.index + 1}"
    Environment = var.environment
    Role        = "application"
  }
}