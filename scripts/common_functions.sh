#!/bin/bash

# Common functions for use across scripts

# Print a message with timestamp
log_message() {
  local level=$1
  local message=$2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}"
}

# Check if a command exists
check_command_exists() {
  if ! command -v "$1" &> /dev/null; then
    log_message "ERROR" "Required command not found: $1"
    return 1
  fi
  return 0
}

# Get the current public IP address
get_public_ip() {
  local ip=$(curl -s ifcfg.me)
  if [ -z "$ip" ]; then
    log_message "ERROR" "Failed to get public IP address"
    return 1
  fi
  echo "${ip}/32"
}

# Wait for a service to be available
wait_for_service() {
  local host=$1
  local port=$2
  local max_attempts=$3
  local attempt=1
  
  log_message "INFO" "Waiting for service on ${host}:${port}..."
  
  while ! nc -z -w 5 "${host}" "${port}" && [ "$attempt" -le "$max_attempts" ]; do
    log_message "INFO" "Attempt $attempt/$max_attempts: Waiting for port ${port} on ${host}..."
    sleep 5
    ((attempt++))
  done
  
  if [ "$attempt" -gt "$max_attempts" ]; then
    log_message "ERROR" "Maximum attempts reached. Service unavailable."
    return 1
  fi
  
  log_message "INFO" "Service is available on ${host}:${port}"
  return 0
}

# Load environment variables
load_env() {
  local env_file=$1
  
  if [ ! -f "$env_file" ]; then
    log_message "ERROR" "Environment file not found: $env_file"
    return 1
  fi
  
  source "$env_file"
  log_message "INFO" "Environment variables loaded from $env_file"
  return 0
}