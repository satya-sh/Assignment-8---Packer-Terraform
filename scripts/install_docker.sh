#!/bin/bash
set -e

# Install Docker
sudo yum install docker -y

# Configure Docker Compose
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
COMPOSE_VERSION="2.33.1"
COMPOSE_BINARY="docker-compose-linux-x86_64"
COMPOSE_URL="https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/${COMPOSE_BINARY}"

# Create directory structure for Docker CLI plugins
mkdir -p $DOCKER_CONFIG/cli-plugins

# Download Docker Compose and make it executable
curl -SL $COMPOSE_URL -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Add the current user to the Docker group
sudo usermod -aG docker ec2-user

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Configure SSH access
mkdir -p ~/.ssh || true
echo "${SSH_PUBLIC_KEY}" >> ~/.ssh/authorized_keys