#!/bin/bash
set -e

# Define constants and paths
ROOT_DIR=$(pwd)
ENV_FILE="${ROOT_DIR}/.env"
PACKER_DIR="${ROOT_DIR}/packer"
TERRAFORM_DIR="${ROOT_DIR}/terraform"
PACKER_LOG="${PACKER_DIR}/packer.log"
IP_DETECTION_SERVICE="ifcfg.me"

# Print function for better output formatting
print_step() {
  echo -e "\n=== $1 ==="
}

# Function to extract AMI ID from Packer logs
extract_ami_id() {
  local ami_id=$(grep -Eo 'ami-[0-9a-f]{17}' "${PACKER_LOG}" | tail -1)
  if [ -z "$ami_id" ]; then
    echo "Error: Could not extract AMI ID from Packer logs" >&2
    exit 1
  fi
  echo "$ami_id"
}

# Function to get current public IP
get_public_ip() {
  local ip=$(curl -s ${IP_DETECTION_SERVICE})
  if [ -z "$ip" ]; then
    echo "Error: Could not detect public IP" >&2
    exit 1
  fi
  echo "${ip}/32"
}

# Load environment variables
print_step "Loading environment variables"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "Warning: .env file not found at $ENV_FILE" >&2
fi

# Extract AMI ID from Packer output
print_step "Extracting AMI ID from Packer logs"
cd "$PACKER_DIR"
AMI_ID=$(extract_ami_id)
echo "Created AMI ID: ${AMI_ID}"

# Get public IP
print_step "Detecting public IP"
MY_IP=$(get_public_ip)
echo "Detected public IP: ${MY_IP}"

# Run Terraform destroy
print_step "Destroying Terraform infrastructure"
cd "$TERRAFORM_DIR"
terraform destroy \
  -auto-approve \
  -var="custom_ami_id=${AMI_ID}" \
  -var="my_ip=${MY_IP}"

print_step "Cleanup completed successfully"