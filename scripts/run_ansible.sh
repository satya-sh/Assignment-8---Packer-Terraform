#!/bin/bash
set -e

# Script to run Ansible playbook against AWS EC2 instances

# Determine directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Navigate to Ansible directory (assumed to be one level up from scripts in a directory called 'ansible')
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")/ansible"
if [ ! -d "$ANSIBLE_DIR" ]; then
  echo "Error: Ansible directory not found at $ANSIBLE_DIR"
  exit 1
fi

cd "$ANSIBLE_DIR"

# Verify that required files exist
if [ ! -f "aws_ec2.yml" ]; then
  echo "Error: aws_ec2.yml inventory file not found in $ANSIBLE_DIR"
  exit 1
fi

if [ ! -f "playbook.yml" ]; then
  echo "Error: playbook.yml not found in $ANSIBLE_DIR"
  exit 1
fi

# Run Ansible playbook with AWS EC2 dynamic inventory
echo "Running Ansible playbook..."
ansible-playbook -i aws_ec2.yml playbook.yml

echo "Ansible playbook execution completed."