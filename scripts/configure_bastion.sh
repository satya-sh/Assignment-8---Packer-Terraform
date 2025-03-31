#!/bin/bash
set -e

# Script to configure the bastion host and run Ansible

# Check if bastion IP was provided
if [ -z "$1" ]; then
  echo "Error: No bastion IP address provided"
  echo "Usage: $0 <bastion_ip>"
  exit 1
fi

# Determine the root directory
ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
SCRIPTS_DIR="${ROOT_DIR}/scripts"
BASTION_IP="$1"

# Source common functions
source "${SCRIPTS_DIR}/common_functions.sh"

# Load environment variables
if ! load_env "${ROOT_DIR}/.env"; then
  exit 1
fi

# Copy environment file to bastion
log_message "INFO" "Copying .env file to bastion host..."
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "${ROOT_DIR}/.env" "ec2-user@${BASTION_IP}:/home/ec2-user/"

# Configure bastion and run Ansible
log_message "INFO" "Connecting to bastion host and running Ansible..."
ssh -A -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "ec2-user@${BASTION_IP}" <<'EOF'
set -e

# Load environment variables
source .env

# Install Git if needed
if ! command -v git &> /dev/null; then
  echo "Installing Git..."
  sudo yum install -y git
else
  echo "Git is already installed: $(git --version)"
fi

# Clone repository with Ansible playbooks
echo "Cloning Ansible playbook repository..."
if [ -d "terraform-ec2-builder" ]; then
  echo "Repository directory already exists, removing it first..."
  rm -rf terraform-ec2-builder
fi

git clone -b multi-os-ec2 --single-branch https://github.com/Sahil1709/terraform-ec2-builder.git
cd terraform-ec2-builder

# Make scripts executable
chmod +x scripts/*

# Install Ansible and run playbook
cd scripts
./install_ansible.sh
./run_ansible.sh
EOF

log_message "SUCCESS" "Bastion host configuration completed successfully."