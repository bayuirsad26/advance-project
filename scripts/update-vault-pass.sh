#!/bin/bash

# SummitEthic Ansible Vault Password Update Script
# This script updates the vault password and re-encrypts all vault files

set -e

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

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Check if the vault password file exists
if [ ! -f .vault_pass ]; then
    print_error "Vault password file not found (.vault_pass)"
    exit 1
fi

print_header "Ansible Vault Password Update"

# Store the old password
OLD_PASS=$(cat .vault_pass)

# Get new password
read -s -p "Enter new Ansible Vault password: " NEW_PASS
echo
read -s -p "Confirm new Ansible Vault password: " CONFIRM_PASS
echo

if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
    print_error "Passwords do not match"
    exit 1
fi

# Create temporary password files
echo "$OLD_PASS" > .vault_pass.old
echo "$NEW_PASS" > .vault_pass.new
chmod 600 .vault_pass.old .vault_pass.new

# Find all vault files
print_header "Finding encrypted vault files"
VAULT_FILES=$(grep -r --include="*.yml" --include="*.yaml" "\$ANSIBLE_VAULT" . | cut -d: -f1 | sort | uniq)

if [ -z "$VAULT_FILES" ]; then
    print_error "No encrypted vault files found"
    rm .vault_pass.old .vault_pass.new
    exit 1
fi

# Re-encrypt each file
print_header "Re-encrypting vault files with new password"
for file in $VAULT_FILES; do
    echo "Processing $file"
    # Decrypt with old password
    ansible-vault decrypt "$file" --vault-password-file .vault_pass.old
    # Encrypt with new password
    ansible-vault encrypt "$file" --vault-password-file .vault_pass.new
done

# Update the vault password file
mv .vault_pass.new .vault_pass
rm .vault_pass.old

print_success "Vault password updated successfully"
echo "The following files were re-encrypted:"
for file in $VAULT_FILES; do
    echo "  - $file"
done

echo -e "\n${YELLOW}IMPORTANT: Make sure to distribute the new password securely to your team!${NC}"