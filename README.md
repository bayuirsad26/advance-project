# SummitEthic Ansible Infrastructure

This repository contains the enhanced Ansible infrastructure codebase for SummitEthic, built on principles of security, modularity, and ethical DevOps practices.

## Features

- **Modular Structure**: Clear separation of concerns for easier maintenance
- **Security-First Approach**: Comprehensive hardening with compliance checks
- **Complete Observability**: Integrated monitoring, logging, and alerting
- **Infrastructure as Code**: Terraform integration for cloud infrastructure
- **CI/CD Integration**: Automated testing and quality checks
- **Documentation**: Extensive documentation and operational guides

## Prerequisites

- Ansible 2.12 or newer
- Python 3.9 or newer
- Required Python packages (install with `pip install -r requirements.txt`):
  - prettytable (for inventory reporting)
  - PyYAML
- Docker and docker-compose-plugin (for containerized services)
- Terraform 1.0+ (for infrastructure provisioning)

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/SummitEthic/summitethic-ansible.git
   cd summitethic-ansible
   ```

2. **Install dependencies**

   ```bash
   make install
   ```

3. **Initialize your workspace**

   ```bash
   make init-workspace
   ```

4. **Create inventory files**

   Copy and modify the example inventory files:

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

5. **Encrypt sensitive data**

   ```bash
   ansible-vault encrypt inventories/production/group_vars/vault.yml
   ```

6. **Bootstrap a new server**

   ```bash
   make bootstrap INVENTORY=production ANSIBLE_ARGS="-e 'ansible_user=root'"
   ```

7. **Deploy the full infrastructure**

   ```bash
   make deploy INVENTORY=production
   ```

## Project Structure

```
summitethic-ansible/
├── ansible.cfg                  # Ansible configuration
├── .github/                     # CI/CD workflows
├── docs/                        # Comprehensive documentation
├── inventories/                 # Environment-specific configurations
│   └── production/              # Production environment
│       ├── group_vars/          # Variable definitions
│       │   ├── all/             # Split variables by category
│       │   │   ├── main.yml     # Core variables
│       │   │   ├── docker.yml   # Docker-related variables
│       │   │   ├── security.yml # Security-related variables
│       │   │   └── services.yml # Service-specific variables
│       │   └── vault.yml        # Encrypted sensitive variables
│       └── inventory.yml        # Main inventory file
├── molecule/                    # Testing framework
├── playbooks/                   # Task playbooks
├── roles/                       # Ansible roles
├── collections/                 # Ansible collections
├── filter_plugins/              # Custom filters
├── scripts/                     # Utility scripts
├── terraform/                   # Infrastructure as Code
├── requirements.yml             # Dependency specifications
├── requirements.txt             # Python dependencies
└── Makefile                     # Automation helpers
```

## Inventory Structure

This project uses a structured approach to organize variables:

- `inventory.yml` - Main inventory file listing servers and groups
- `group_vars/all/` - Split variable files by category:
  - `main.yml` - Core system variables
  - `docker.yml` - Docker configuration
  - `security.yml` - Security settings
  - `services.yml` - Application service parameters
- `group_vars/vault.yml` - Encrypted sensitive variables

## Available Playbooks

- **bootstrap.yml**: Initial server setup
- **site.yml**: Complete infrastructure deployment
- **security.yml**: Security hardening and auditing
- **monitoring.yml**: Observability stack deployment
- **maintenance.yml**: System maintenance operations
- **backup.yml**: Backup management

## Roles

- **common**: Base system configuration
- **root_setup**: Initial bootstrap process
- **security**: Comprehensive security hardening
- **user_setup**: User configuration and SSH setup
- **traefik**: Reverse proxy setup
- **mailcow**: Mail server deployment
- **monitoring**: Observability stack
- **logging**: Centralized logging
- **backup**: Backup management

## Troubleshooting

### Common Issues

- **Missing inventory errors**: Ensure you have copied example files to create your inventory structure
- **Linting failures**: Run `ansible-lint` to identify and fix code style issues
- **Missing roles or task files**: The project expects certain files like security.yml and monitoring.yml in role directories

For more detailed troubleshooting, see the [Troubleshooting Guide](docs/troubleshooting.md).

## Documentation

- [Contributing Guide](CONTRIBUTING.md) - How to contribute to this project
- [Inventory Guide](docs/inventory-guide.md) - Detailed explanation of inventory structure
- [Security Practices](docs/security-practices.md) - Overview of security hardening measures
- [Linting Guide](docs/linting-guide.md) - Standards and fixes for code quality

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Security

For security concerns, please contact security@summitethic.com instead of opening a public issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
