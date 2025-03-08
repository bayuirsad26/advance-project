# Troubleshooting Guide

This guide addresses common issues you might encounter while using the SummitEthic Ansible infrastructure.

## Table of Contents

- [Ansible Linting Issues](#ansible-linting-issues)
- [Inventory Problems](#inventory-problems)
- [Role and Task Errors](#role-and-task-errors)
- [Docker and Container Issues](#docker-and-container-issues)
- [Python Dependencies](#python-dependencies)

## Ansible Linting Issues

### Missing Files Errors

**Issue**: Errors like `load-failure[filenotfounderror]: No such file or directory: 'monitoring.yml'`

**Solution**:

1. Check which role is missing the file:
   ```bash
   grep -r "monitoring.yml" --include="*.yml" .
   ```
2. Create the missing file in the role's tasks directory:
   ```bash
   touch roles/mailcow/tasks/monitoring.yml
   ```
3. Add minimal content to make it functional:
   ```yaml
   ---
   # Monitoring tasks for mailcow
   - name: Check if monitoring is enabled
     ansible.builtin.stat:
       path: /opt/monitoring
     register: monitoring_dir
     tags: [mailcow, monitoring]
   ```

### Line Length Warnings

**Issue**: Warnings like `yaml[line-length]: Line too long (168 > 120 characters)`

**Solution**: Use YAML's multi-line syntax with `>-` or `|-`:

```yaml
# Before
very_long_line: "This is a very long line that exceeds the 120 character limit and causes linting warnings"

# After
very_long_line: >-
  This is a very long line that has been split
  into multiple lines to stay within the 120
  character limit
```

### Comment Spacing Issues

**Issue**: Warnings like `yaml[comments]: Too few spaces before comment`

**Solution**: Ensure there's a space after the `#` character:

```yaml
# Good comment (space after #)
#Bad comment (needs a space)
```

## Inventory Problems

### Unable to Parse Inventory

**Issue**: Warning `Unable to parse /path/to/inventory.yml as an inventory source`

**Solutions**:

1. Check if the file exists and has correct permissions:

   ```bash
   ls -la inventories/production/
   chmod 644 inventories/production/inventory.yml
   ```

2. Validate the YAML syntax:

   ```bash
   python3 -c "import yaml; yaml.safe_load(open('inventories/production/inventory.yml'))"
   ```

3. Ensure it follows Ansible inventory format:

   ```yaml
   all:
     hosts:
       server1:
         ansible_host: 192.168.1.10
     children:
       web_servers:
         hosts:
           server1:
   ```

4. Create a symbolic link if you have hosts.yml but not inventory.yml:
   ```bash
   ln -s inventories/production/hosts.yml inventories/production/inventory.yml
   ```

### Missing Host Patterns

**Issue**: Warning `Could not match supplied host pattern`

**Solution**: Ensure the hosts or groups referenced in playbooks exist in your inventory. For testing, you can use localhost:

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
  children:
    mail_servers:
      hosts:
        localhost:
    monitoring_servers:
      hosts:
        localhost:
```

## Role and Task Errors

### Missing Handler

**Issue**: Error referencing a handler that doesn't exist

**Solution**: Define all handlers referenced in tasks:

```yaml
# In roles/example/handlers/main.yml
- name: Restart service
  ansible.builtin.service:
    name: example
    state: restarted
```

### Module Not Found

**Issue**: Error like `The module community.general.yaml_edit was not found`

**Solution**: Install the required collection:

```bash
ansible-galaxy collection install community.general
```

## Docker and Container Issues

### Docker Compose Errors

**Issue**: Errors using deprecated Docker Compose syntax

**Solution**: Update to use the docker-compose plugin:

```yaml
# Change this
docker_compose:
  project_src: /path/to/project

# To this
community.docker.docker_compose_v2:
  project_src: /path/to/project
```

### Container Connectivity Issues

**Issue**: Containers can't connect to each other or external network

**Solution**: Check network configuration:

```bash
docker network ls
docker inspect traefik-public
```

Ensure your docker-compose files reference existing networks:

```yaml
networks:
  traefik-public:
    external: true
```

## Python Dependencies

### Missing Python Modules

**Issue**: Import errors like `Import "prettytable" could not be resolved`

**Solution**: Install the required Python packages:

```bash
pip install -r requirements.txt
```

If requirements.txt doesn't exist, create it:

```
prettytable
PyYAML
ansible-lint
molecule
docker
```

### Python Version Compatibility

**Issue**: Errors due to incompatible Python versions

**Solution**: Check and use a compatible Python version:

```bash
python3 --version  # Should be 3.9+ for best compatibility
```

Consider using pyenv to manage multiple Python versions if needed.
