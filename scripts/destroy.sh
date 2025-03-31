#!/bin/bash

ROOT_DIR=$(pwd)
source "${ROOT_DIR}/.env"
cd "${ROOT_DIR}/packer"

# Get public IP
MY_IP=$(curl -s ifcfg.me)/32
echo "Detected public IP: ${MY_IP}"

cd "${ROOT_DIR}/terraform"
# Run the terraform destroy command to destroy the infrastructure
terraform destroy \
    -auto-approve \
    -var="my_ip=${MY_IP}"