#!/bin/bash
set -e

# Set scripts executable
chmod +x scripts/*

# Set paths
ROOT_DIR=$(pwd)
PACKER_DIR="${ROOT_DIR}/packer"
TERRAFORM_DIR="${ROOT_DIR}/terraform"
SSH_DIR="${ROOT_DIR}/.ssh"

source .env
chmod 600 $SSH_KEY_PATH
ssh-add $SSH_KEY_PATH

# Get public IP
MY_IP=$(curl -s ifcfg.me)/32
echo "Detected public IP: ${MY_IP}"

# Run Terraform
echo "Initializing Terraform..."
cd "${TERRAFORM_DIR}"
if [ ! -d ".terraform" ]; then
  echo "Terraform not initialized. Initializing now..."
  terraform init
else
  echo "Terraform already initialized. Skipping initialization."
fi

echo "Planning infrastructure..."
terraform plan \
  -var="my_ip=${MY_IP}"

echo "Applying infrastructure..."
terraform apply \
  -var="my_ip=${MY_IP}" \
  -auto-approve

echo "Deployment complete!"

BASTION_IP=$(terraform output -raw bastion_public_ip)
echo "Bastion IP: ${BASTION_IP}"
echo "SSH Key Path: ${SSH_KEY_PATH}"

cd "$ROOT_DIR"

echo "Waiting for Bastion SSH availability..."
while ! nc -z -w 5 ${BASTION_IP} 22; do
    echo "Waiting for port 22 on ${BASTION_IP}..."
    sleep 5
done

echo "Copying .env to Bastion host..."
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null .env ec2-user@${BASTION_IP}:/home/ec2-user/

# SSH into the Bastion host and run the install_ansible script, source .env, and then run the ansible playbook.
echo "Connecting to Bastion and running ansible..."
ssh -A -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${BASTION_IP} <<'EOF'
source .env
echo "Installing dependencies..."
if ! command -v git &> /dev/null
then
    echo "Git is not installed. Installing Git..."
    sudo yum install -y git
else
    echo "Git is already installed."
fi

echo "Cloning Ansible playbook repository..."
git clone -b multi-os-ec2 --single-branch https://github.com/Sahil1709/terraform-ec2-builder.git
cd terraform-ec2-builder
chmod +x scripts/*
cd scripts
./install_ansible.sh
./run_ansible.sh
EOF

echo "run_now.sh script completed successfully."


