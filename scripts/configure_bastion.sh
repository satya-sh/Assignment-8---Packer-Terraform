#!/bin/bash
set -e

# Script to configure the bastion host and run Ansible

# Check if bastion IP was provided
if [ -z "$1" ]; then
  echo "Error: No bastion IP address provided"
  echo "Usage: $0 <bastion_ip>"
  exit 1
fi

# Get the bastion IP parameter
BASTION_IP="$1"

# Strip any stray whitespace/newlines from $BASTION_IP
BASTION_IP="$(echo "$BASTION_IP" | tr -d '[:space:]')"

# Debug output to detect hidden characters
echo "DEBUG: BASTION_IP raw input was '$1'"
echo "DEBUG: BASTION_IP stripped is '$BASTION_IP'"
echo "DEBUG cat -v output:"
echo "$BASTION_IP" | cat -v
echo "-----------"

# Determine the repository's root directory
ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}"

# Load environment variables if .env exists
if [ -f "${ROOT_DIR}/.env" ]; then
  source "${ROOT_DIR}/.env"
fi

# Create a simple env file to transfer
echo "Creating temporary .env file for transfer..."
cat > /tmp/simple.env << EOF
# Environment variables for bastion host
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
EOF

# Copy environment file to bastion using SCP
echo "Copying environment file to bastion host..."
scp -i "${SSH_KEY_PATH}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  /tmp/simple.env "ec2-user@${BASTION_IP}:.env"

# Configure bastion and run Ansible
echo "Connecting to bastion host and running Ansible..."
ssh -A -i "${SSH_KEY_PATH}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
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

# Install Ansible and run the playbook
cd scripts
./install_ansible.sh
./run_ansible.sh
EOF

echo "Bastion host configuration completed successfully."
