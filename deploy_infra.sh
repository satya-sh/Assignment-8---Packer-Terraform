#!/bin/bash
set -e

# Set paths
ROOT_DIR=$(pwd)
TERRAFORM_DIR="${ROOT_DIR}/terraform"

# Check for AMI ID and IP files
if [ ! -f "${ROOT_DIR}/ami_id.txt" ] || [ ! -f "${ROOT_DIR}/my_ip.txt" ]; then
  echo "Error: Missing AMI ID or IP information. Run build_ami.sh first."
  exit 1
fi

# Get AMI ID and public IP
AMI_ID=$(cat "${ROOT_DIR}/ami_id.txt")
MY_IP=$(cat "${ROOT_DIR}/my_ip.txt")

echo "Using AMI ID: ${AMI_ID}"
echo "Using public IP: ${MY_IP}"

# Run Terraform
echo "Initializing Terraform..."
cd "${TERRAFORM_DIR}"
terraform init

echo "Planning infrastructure..."
terraform plan \
  -var="custom_ami_id=${AMI_ID}" \
  -var="my_ip=${MY_IP}"

echo "Applying infrastructure..."
terraform apply \
  -var="custom_ami_id=${AMI_ID}" \
  -var="my_ip=${MY_IP}" \
  -auto-approve

echo "Deployment complete!"