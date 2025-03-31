resource "aws_instance" "bastion" {
  ami                         = var.amazon_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  
  tags = {
    Name = "Bastion Host (Ansible Controller)"
  }
}

resource "aws_instance" "private_instances" {
  count         = var.num_private_instances
  ami           = count.index < 3 ? var.ubuntu_ami_id : var.amazon_ami_id
  instance_type = var.private_instance_type
  key_name      = var.key_name
  
  # Distribute instances across private subnets using modulus
  subnet_id              = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids = [var.private_sg_id]
  
  tags = {
    Name = "Private Instance ${count.index + 1}"
    OS   = count.index < 3 ? "ubuntu" : "amazon"
  }
}