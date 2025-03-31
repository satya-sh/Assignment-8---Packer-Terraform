provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow SSH only from my IP on port 22"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name        = "private-sg"
  description = "Allow SSH from bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.amazon_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = "vockey"
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host (Ansible Controller)"
  }
}

# 6 Private instances: first 3 Ubuntu, next 3 Amazon Linux
resource "aws_instance" "private_instances" {
  count                  = var.num_private_instances
  ami                    = count.index < 3 ? var.ubuntu_ami_id : var.amazon_ami_id
  instance_type          = var.private_instance_type
  key_name               = "vockey"
  # Distribute instances across private subnets (using modulus operator for balance)
  subnet_id              = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "Private Instance ${count.index + 1}"
    OS   = count.index < 3 ? "ubuntu" : "amazon"
  }
}