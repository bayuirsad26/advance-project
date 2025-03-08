#!/bin/bash

# SummitEthic Ansible Bootstrap Script
# This script helps set up a new server to be managed by Ansible

set -e

# Configuration
SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
ADMIN_USER="summitethic"
DEFAULT_INVENTORY="production"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${GREEN}===== $1 =====${NC}\n"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

check_dependencies() {
    print_header "Checking dependencies"
    
    for cmd in ansible-playbook ssh sshpass python3; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd could not be found. Please install it first."
            exit 1
        fi
    done
    
    print_success "All dependencies are installed"
}

generate_ssh_key() {
    if [ ! -f "$SSH_KEY_PATH" ]; then
        print_header "Generating SSH key"
        ssh-keygen -t ed25519 -f "${SSH_KEY_PATH%.pub}" -N ""
        print_success "SSH key generated at $SSH_KEY_PATH"
    else
        print_success "SSH key already exists at $SSH_KEY_PATH"
    fi
}

check_vault_password() {
    if [ ! -f .vault_pass ]; then
        print_header "Setting up Vault password"
        read -s -p "Enter Ansible Vault password: " VAULT_PASS
        echo
        echo "$VAULT_PASS" > .vault_pass
        chmod 600 .vault_pass
        print_success "Vault password saved to .vault_pass"
    else
        print_success "Vault password file already exists"
    fi
}

run_bootstrap() {
    print_header "Running bootstrap playbook"
    
    # Get server information
    read -p "Enter server hostname or IP: " SERVER_HOST
    read -p "Enter SSH port [22]: " SSH_PORT
    SSH_PORT=${SSH_PORT:-22}
    
    read -p "Enter inventory to use [$DEFAULT_INVENTORY]: " INVENTORY
    INVENTORY=${INVENTORY:-$DEFAULT_INVENTORY}
    
    # Check if we need a password for initial access
    read -p "Do you need to use a password for initial root access? (y/n) [n]: " USE_PASSWORD
    USE_PASSWORD=${USE_PASSWORD:-n}
    
    EXTRA_OPTS=""
    if [[ $USE_PASSWORD == "y" ]]; then
        read -s -p "Enter root password: " ROOT_PASS
        echo
        EXTRA_OPTS="-e ansible_user=root -e ansible_password=$ROOT_PASS -e ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    fi
    
    # Create temporary inventory file
    mkdir -p "inventories/$INVENTORY"
    echo "[bootstrap]" > "inventories/$INVENTORY/temp-inventory.ini"
    echo "$SERVER_HOST ansible_port=$SSH_PORT" >> "inventories/$INVENTORY/temp-inventory.ini"
    
    # Ensure vault.yml exists
    if [ ! -f "inventories/$INVENTORY/group_vars/vault.yml" ]; then
        mkdir -p "inventories/$INVENTORY/group_vars"
        echo "---" > "inventories/$INVENTORY/group_vars/vault.yml"
        echo "vault_root_setup_pass: 'changeme'" >> "inventories/$INVENTORY/group_vars/vault.yml"
        ansible-vault encrypt "inventories/$INVENTORY/group_vars/vault.yml"
    fi
    
    # Run playbook
    eval "ansible-playbook -i inventories/$INVENTORY/temp-inventory.ini playbooks/bootstrap.yml $EXTRA_OPTS"
    
    # Clean up
    rm "inventories/$INVENTORY/temp-inventory.ini"
    
    print_success "Bootstrap completed successfully"
    echo "The server is now ready to be added to your regular inventory."
    echo "Please update 'inventories/$INVENTORY/inventory.yml' with the server details."
}

# Main execution
echo -e "${GREEN}SummitEthic Ansible Bootstrap Script${NC}"
echo "This script will help you bootstrap a new server for Ansible management"

check_dependencies
generate_ssh_key
check_vault_password
run_bootstrap