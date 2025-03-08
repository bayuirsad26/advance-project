# Ansible Inventory Guide

This guide explains how to effectively manage your inventory structure in the SummitEthic Ansible infrastructure.

## Inventory Organization

The project uses a structured inventory organization:

```
inventories/
└── production/
    ├── group_vars/
    │   ├── all/
    │   │   ├── main.yml
    │   │   ├── docker.yml
    │   │   ├── security.yml
    │   │   └── services.yml
    │   └── vault.yml
    └── inventory.yml
```

## Getting Started with Inventory

Start by copying the example files to create your working inventory:

```bash
# Create inventory structure from examples
cp inventories/production/inventory.yml.example inventories/production/inventory.yml
mkdir -p inventories/production/group_vars/all
cp inventories/production/group_vars/all/main.yml.example inventories/production/group_vars/all/main.yml
cp inventories/production/group_vars/all/docker.yml.example inventories/production/group_vars/all/docker.yml
cp inventories/production/group_vars/all/security.yml.example inventories/production/group_vars/all/security.yml
cp inventories/production/group_vars/all/services.yml.example inventories/production/group_vars/all/services.yml
cp inventories/production/group_vars/vault.yml.example inventories/production/group_vars/vault.yml
```

## Inventory File Format

The main inventory file is `inventory.yml`. Here's a template:

```yaml
---
all:
  hosts:
    localhost:
      ansible_connection: local

  children:
    mail_servers:
      hosts:
        mail.example.com:
          ansible_host: 192.168.1.10

    web_servers:
      hosts:
        web.example.com:
          ansible_host: 192.168.1.11

    monitoring_servers:
      hosts:
        monitor.example.com:
          ansible_host: 192.168.1.12
```

### Key Components

1. **All Group**: Contains all hosts in the inventory
2. **Children Groups**: Functional groupings of hosts (mail_servers, web_servers, etc.)
3. **Host Variables**: Defined inline for each host

## Variable Precedence

Ansible uses a specific precedence order for variables. From lowest to highest precedence:

1. Role defaults (`roles/x/defaults/main.yml`)
2. Inventory variables (`group_vars/all/`)
3. Group variables (`group_vars/<group>/`)
4. Host variables (`host_vars/<host>/`)
5. Play variables (in playbooks)
6. Command-line variables (`-e` or `--extra-vars`)

## Split Variable Files

We use a split variable approach for better organization:

```
group_vars/
└── all/
    ├── main.yml     # Core variables
    ├── docker.yml   # Docker-related variables
    ├── security.yml # Security-related variables
    └── services.yml # Service-specific variables
```

This makes it easier to manage related variables together and reduces merge conflicts.

## Example Variable Files

Below are examples of what each variable file should contain:

**group_vars/all/main.yml**:

```yaml
---
# Main variables for production environment
environment: production
ansible_user: summitethic

# Domain configuration
domain: summitethic.europe
```

**group_vars/all/security.yml**:

```yaml
---
# Security variables for all hosts
security:
  # SSH configuration
  ssh:
    permit_root_login: "no"
    password_auth: "no"

  # Firewall configuration
  firewall:
    enabled: true
    default_policy: deny
    rules:
      - { port: 22, proto: tcp, rule: allow }
      - { port: 80, proto: tcp, rule: allow }
      - { port: 443, proto: tcp, rule: allow }
```

**group_vars/all/docker.yml**:

```yaml
---
# Docker configuration
docker:
  compose_version: "v2"
  network_settings:
    bip: "172.18.0.1/24"
  log_settings:
    max_size: "10m"
    max_file: "3"
  networks:
    - name: traefik-public
      driver: bridge
```

**group_vars/all/services.yml**:

```yaml
---
# Service configuration
traefik:
  acme_email: "admin@summitethic.europe"
  image: traefik:v2.9
  domain: "{{ domain }}"

mailcow:
  hostname: "mail.{{ domain }}"
  tz: UTC
  dbname: mailcow
  dbuser: mailcowuser
  dbpass: "{{ vault_mailcow_dbpass }}"
```

## Vault Integration

Sensitive variables should be stored in an encrypted vault file:

```bash
# Create vault file
ansible-vault create inventories/production/group_vars/vault.yml

# Edit existing vault file
ansible-vault edit inventories/production/group_vars/vault.yml

# Structure of vault.yml
---
vault_mailcow_dbpass: "secure_password_here"
vault_mailcow_dbroot: "secure_root_password_here"
vault_traefik_dashboard_auth: "admin:hashed_password_here"
```

Reference vault variables in other files:

```yaml
mailcow:
  dbpass: "{{ vault_mailcow_dbpass }}"
```

## Testing Your Inventory

Use the inventory report script to view your inventory structure:

```bash
./scripts/inventory-report.py production
```

This script generates a human-readable report of your hosts, groups, and variables.

## Troubleshooting Inventory Issues

### Missing Example Files

If you cannot find the example files, check that you have the latest version of the repository:

```bash
git pull origin main
```

### Creating Additional Environments

To create additional environments (like development or staging), copy the production structure:

```bash
cp -r inventories/production inventories/development
```

Then update the variables appropriately for the new environment.

### Invalid YAML Syntax

If Ansible can't parse your inventory, check YAML syntax:

```bash
python3 -c "import yaml; yaml.safe_load(open('inventories/production/inventory.yml'))"
```

## Best Practices

1. **Start from Examples**: Always base your configuration on the provided example files
2. **Encrypt Sensitive Data**: Use ansible-vault for all passwords and secrets
3. **Keep Variables Organized**: Maintain the categorized variable structure
4. **Document Variables**: Add comments explaining variable purpose and format
5. **Consistent Naming**: Maintain consistent naming conventions
6. **Validate Changes**: Test inventory changes with a syntax check before deploying

Following these guidelines will help maintain a clean, secure, and maintainable inventory structure for your SummitEthic infrastructure.
