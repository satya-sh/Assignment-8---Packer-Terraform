#!/bin/bash
set -e

# Set paths
ROOT_DIR=$(pwd)

echo "===========================================" 
echo "Starting full deployment process"
echo "===========================================" 

# Build AMI with Packer
echo "STEP 1: Building AMI with Packer"
echo "-------------------------------------------"
./build_ami.sh

# Deploy infrastructure with Terraform
echo "STEP 2: Deploying infrastructure with Terraform"
echo "-------------------------------------------"
./deploy_infra.sh

echo "===========================================" 
echo "Deployment completed successfully!"
echo "==========================================="