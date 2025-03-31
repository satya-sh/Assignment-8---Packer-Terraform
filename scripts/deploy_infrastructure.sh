#!/bin/bash
set -e

# Script to deploy infrastructure using Terraform

# Determine the root directory
ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
SCRIPTS_DIR="${ROOT_DIR}/scripts"
TERRAFORM_DIR="${ROOT_DIR}/terraform"

# Source common functions
source "${SCRIPTS_DIR}/common_functions.sh"

# Load environment variables
if ! load_env "${ROOT_DIR}/.env"; then
  exit 1
fi

# Get public IP for security group configuration
log_message "INFO" "Detecting public IP address..."
MY_IP=$(get_public_ip)
log_message "INFO" "Detected public IP: ${MY_IP}"

# Navigate to Terraform directory
cd "${TERRAFORM_DIR}"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
  log_message "INFO" "Initializing Terraform..."
  terraform init
else
  log_message "INFO" "Terraform already initialized"
fi

# Plan infrastructure
log_message "INFO" "Planning infrastructure..."
terraform plan -var="my_ip=${MY_IP}"

# Apply infrastructure
log_message "INFO" "Applying infrastructure..."
terraform apply -var="my_ip=${MY_IP}" -auto-approve

# Get bastion host IP
BASTION_IP=$(terraform output -raw bastion_public_ip)
if [ -z "$BASTION_IP" ]; then
  log_message "ERROR" "Failed to get bastion host IP address"
  exit 1
fi
log_message "INFO" "Bastion host IP: ${BASTION_IP}"

# Wait for SSH to be available
wait_for_service "${BASTION_IP}" 22 20

# Return the bastion IP to the calling script
echo "${BASTION_IP}"