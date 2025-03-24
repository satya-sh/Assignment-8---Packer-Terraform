#!/bin/bash
set -e

# Set paths
ROOT_DIR=$(pwd)
PACKER_DIR="${ROOT_DIR}/packer"
SSH_DIR="${ROOT_DIR}/.ssh"

# Make scripts executable
chmod +x scripts/*

# Install Packer Plugins
echo "Checking if Packer plugins are installed..."
if ! packer plugins installed | grep -q 'github.com/hashicorp/amazon'; then
  echo "Installing Packer plugins..."
  packer plugins install github.com/hashicorp/amazon
else
  echo "Required Packer plugins are already installed."
fi

# Create SSH directory and set permissions
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Generate SSH key pair if not exists
if [ ! -f "${SSH_DIR}/id_rsa" ]; then
  echo "Generating new SSH key pair..."
  ssh-keygen -t rsa -b 4096 -N "" -f "${SSH_DIR}/id_rsa"
  chmod 600 "${SSH_DIR}/id_rsa"
  chmod 644 "${SSH_DIR}/id_rsa.pub"
fi

# Export SSH public key
SSH_PUBLIC_KEY=$(cat "${SSH_DIR}/id_rsa.pub")
export SSH_PUBLIC_KEY

# Load environment variables
source .env

# Build Packer image
echo "Building Packer AMI..."
cd "${PACKER_DIR}"
packer build amazon-linux.json | tee packer.log

# Extract AMI ID from Packer output
AMI_ID=$(grep -Eo 'ami-[0-9a-f]{17}' packer.log | tail -1)
echo "Created AMI ID: ${AMI_ID}"
echo "${AMI_ID}" > "${ROOT_DIR}/ami_id.txt"

# Get public IP
MY_IP=$(curl -s ifcfg.me)/32
echo "Detected public IP: ${MY_IP}"
echo "${MY_IP}" > "${ROOT_DIR}/my_ip.txt"

echo "Packer build complete!"