#!/bin/bash
set -e

# Script to set up the environment before deployment

# Determine the root directory
ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
SCRIPTS_DIR="${ROOT_DIR}/scripts"

# Source common functions
source "${SCRIPTS_DIR}/common_functions.sh"

# Load environment variables
if ! load_env "${ROOT_DIR}/.env"; then
  exit 1
fi

# Check required commands
log_message "INFO" "Checking required commands..."
for cmd in terraform ssh nc curl git; do
  if ! check_command_exists "$cmd"; then
    log_message "ERROR" "Required command not found: $cmd"
    exit 1
  fi
done

# Validate and set up SSH key
if [ ! -f "$SSH_KEY_PATH" ]; then
  log_message "ERROR" "SSH key not found at $SSH_KEY_PATH"
  exit 1
fi

log_message "INFO" "Setting proper permissions for SSH key..."
chmod 600 "$SSH_KEY_PATH"

log_message "INFO" "Adding SSH key to SSH agent..."
if ! ssh-add "$SSH_KEY_PATH" 2>/dev/null; then
  log_message "WARNING" "Could not add SSH key to agent. Make sure ssh-agent is running. Continuing anyway."
fi

log_message "SUCCESS" "Environment setup completed successfully."