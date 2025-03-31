#!/bin/bash
set -e

# Script to destroy the infrastructure created by Terraform

# Navigate to root directory and load environment variables
ROOT_DIR=$(pwd)
if [ -f "${ROOT_DIR}/.env" ]; then
  source "${ROOT_DIR}/.env"
else
  echo "Error: .env file not found in ${ROOT_DIR}"
  exit 1
fi

# Get current public IP
echo "Detecting current public IP address..."
MY_IP=$(curl -s ifcfg.me)/32
echo "Detected public IP: ${MY_IP}"

# Navigate to Terraform directory and destroy infrastructure
echo "Destroying infrastructure..."
cd "${ROOT_DIR}/terraform"
terraform destroy \
  -auto-approve \
  -var="my_ip=${MY_IP}"

echo "Infrastructure successfully destroyed."