#!/bin/bash
set -e
cd ../ansible
echo "Running Ansible..."
ansible-playbook -i aws_ec2.yml playbook.yml