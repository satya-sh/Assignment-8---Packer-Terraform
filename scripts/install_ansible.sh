#1!/bin/bash
set -e
if ! command -v python3 &> /dev/null
then
    echo "Python3 is not installed. Installing Python 3.9..."
    sudo yum install -y python39
else
    echo "Python3 is already installed."
fi

echo "Installing pip..."
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

pip install boto3 botocore

echo "Installing pipx..."
pip install --user pipx
pipx ensurepath

echo "Installing Ansible..."
pipx install --include-deps ansible

pipx inject ansible boto3 botocore


