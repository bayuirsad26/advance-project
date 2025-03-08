# SummitEthic Ansible Infrastructure

This repository contains the enhanced Ansible infrastructure codebase for SummitEthic, built on principles of security, modularity, and ethical DevOps practices.

## Features

- **Modular Structure**: Clear separation of concerns for easier maintenance
- **Security-First Approach**: Comprehensive hardening with compliance checks
- **Complete Observability**: Integrated monitoring, logging, and alerting
- **Infrastructure as Code**: Terraform integration for cloud infrastructure
- **CI/CD Integration**: Automated testing and quality checks
- **Documentation**: Extensive documentation and operational guides

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
   cp inventories/production/inventory.yml.example inventories/production/inventory.yml
   cp inventories/production/group_vars/all.yml.example inventories/production/group_vars/all/main.yml
   cp inventories/production/group_vars/vault.yml.example inventories/production/group_vars/vault.yml
   ```

5. **Encrypt sensitive data**

   ```bash
   ansible-vault encrypt inventories/production/group_vars/vault.yml
   ```

6. **Bootstrap a new server**

   ```bash
   make bootstrap INVENTORY=production
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
├── molecule/                    # Testing framework
├── playbooks/                   # Task playbooks
├── roles/                       # Ansible roles
├── collections/                 # Ansible collections
├── filter_plugins/              # Custom filters
├── scripts/                     # Utility scripts
├── terraform/                   # Infrastructure as Code
├── requirements.yml             # Dependency specifications
└── Makefile                     # Automation helpers
```

## Available Playbooks

- **bootstrap.yml**: Initial server setup
- **site.yml**: Complete infrastructure deployment
- **security.yml**: Security hardening and auditing
- **monitoring.yml**: Observability stack deployment
- **maintenance.yml**: System maintenance operations
- **backup.yml**: Backup management

## Roles

- **common**: Base system configuration
- **security**: Comprehensive security hardening
- **traefik**: Reverse proxy setup
- **mailcow**: Mail server deployment
- **monitoring**: Observability stack
- **logging**: Centralized logging
- **backup**: Backup management

## Contributing

Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Security

For security concerns, please contact security@summitethic.com instead of opening a public issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
