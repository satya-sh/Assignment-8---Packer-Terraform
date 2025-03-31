#!/bin/bash
set -e

# Script to install Ansible and required dependencies

# Install Python 3 if not already installed
if ! command -v python3 &> /dev/null; then
  echo "Python3 is not installed. Installing Python 3.9..."
  sudo yum install -y python39
else
  echo "Python3 is already installed: $(python3 --version)"
fi

# Install pip
echo "Installing pip..."
if ! command -v pip &> /dev/null; then
  curl -s -O https://bootstrap.pypa.io/get-pip.py
  python3 get-pip.py
  rm get-pip.py
else
  echo "Pip is already installed: $(pip --version)"
fi

# Install AWS SDK for Python
echo "Installing AWS SDK for Python..."
pip install --user boto3 botocore

# Install pipx for isolated Python application installation
echo "Installing pipx..."
if ! command -v pipx &> /dev/null; then
  pip install --user pipx
  pipx ensurepath
else
  echo "Pipx is already installed: $(pipx --version)"
fi

# Install Ansible with required dependencies
echo "Installing Ansible with AWS modules..."
pipx install --include-deps ansible
pipx inject ansible boto3 botocore

echo "Ansible installation complete: $(ansible --version | head -n1)"