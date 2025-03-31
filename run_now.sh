#!/bin/bash
set -e

# Master orchestration script that calls individual modules in sequence

# Set up initial variables
ROOT_DIR=$(pwd)
SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV_FILE="${ROOT_DIR}/.env"

# Source common functions
source "${SCRIPTS_DIR}/common_functions.sh"

# Set execute permissions for all scripts
log_message "INFO" "Setting execute permissions on scripts..."
chmod +x "${SCRIPTS_DIR}"/*.sh

# Load environment variables
if ! load_env "${ENV_FILE}"; then
  exit 1
fi

# Step 1: Setup SSH and environment
log_message "INFO" "Setting up SSH and environment..."
"${SCRIPTS_DIR}/setup_environment.sh"

# Step 2: Deploy infrastructure with Terraform
log_message "INFO" "Deploying infrastructure with Terraform..."
BASTION_IP=$("${SCRIPTS_DIR}/deploy_infrastructure.sh")

# Step 3: Configure bastion host
log_message "INFO" "Configuring bastion host..."
"${SCRIPTS_DIR}/configure_bastion.sh" "${BASTION_IP}"

log_message "SUCCESS" "Deployment and configuration completed successfully!"