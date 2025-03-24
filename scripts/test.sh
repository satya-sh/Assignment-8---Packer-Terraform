#!/bin/bash
set -e

# Constants
SSH_USER="ec2-user"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"
SUCCESS_BASTION_MSG="Successfully connected to bastion host"
SUCCESS_PRIVATE_MSG="Successfully connected to private instance"

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
KEY_FILE="$PROJECT_ROOT/.ssh/id_rsa"

# Navigate to Terraform directory
cd "$PROJECT_ROOT/terraform"

# Get Terraform outputs
BASTION_IP=$(terraform output -raw bastion_public_ip)
PRIVATE_IPS=$(terraform output -json private_instance_ips | jq -r '.[]')

# Verify SSH key exists
if [ ! -f "$KEY_FILE" ]; then
  echo "Error: SSH key not found at $KEY_FILE"
  exit 1
fi

# Set proper permissions and add key to SSH agent
chmod 600 "$KEY_FILE"
ssh-add "$KEY_FILE"

# Function to test SSH connection
test_connection() {
  local target_type="$1"
  local target_ip="$2"
  local command="$3"
  local success_msg="$4"
  
  echo "Testing SSH to $target_type ($target_ip)..."
  eval "$command"
  echo "✓ Connection to $target_type successful"
}

# Test bastion connection
test_connection "bastion host" "$BASTION_IP" \
  "ssh -i \"$KEY_FILE\" $SSH_OPTIONS $SSH_USER@$BASTION_IP \"echo '$SUCCESS_BASTION_MSG'\"" \
  "$SUCCESS_BASTION_MSG"

# Test private instance connections
for IP in $PRIVATE_IPS; do
  test_connection "private instance" "$IP" \
    "ssh -i \"$KEY_FILE\" $SSH_OPTIONS -J $SSH_USER@$BASTION_IP $SSH_USER@$IP \"echo '$SUCCESS_PRIVATE_MSG'\"" \
    "$SUCCESS_PRIVATE_MSG"
done

echo "All tests completed successfully!"