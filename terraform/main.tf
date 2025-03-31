provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  environment     = var.environment
}

module "security" {
  source = "./modules/security"
  
  vpc_id          = module.network.vpc_id
  my_ip           = var.my_ip
}

module "compute" {
  source = "./modules/compute"
  
  bastion_instance_type  = var.bastion_instance_type
  private_instance_type  = var.private_instance_type
  num_private_instances  = var.num_private_instances
  ubuntu_ami_id          = var.ubuntu_ami_id
  amazon_ami_id          = var.amazon_ami_id
  bastion_sg_id          = module.security.bastion_sg_id
  private_sg_id          = module.security.private_sg_id
  public_subnet_id       = module.network.public_subnets[0]
  private_subnet_ids     = module.network.private_subnets
  key_name               = var.key_name
}