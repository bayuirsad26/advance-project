# Security Practices

This document outlines the security hardening measures implemented in the SummitEthic Ansible infrastructure.

## Security Philosophy

Our security approach is based on defense-in-depth principles:

1. **Least Privilege**: Systems and users have only the permissions they need
2. **Defense in Depth**: Multiple layers of security controls
3. **Secure by Default**: Secure configurations are applied automatically
4. **Continuous Validation**: Regular security checks and compliance validation
5. **Transparent Security**: Clear documentation of security measures

## System Hardening

### SSH Hardening

Our infrastructure implements the following SSH hardening measures:

```yaml
# SSH configuration in security role
security_ssh_permit_root_login: "no"
security_ssh_password_auth: "no"
security_ssh_x11_forwarding: "no"
security_ssh_max_auth_tries: 3
security_ssh_allow_agent_forwarding: "no"
security_ssh_allow_tcp_forwarding: "no"
security_ssh_max_sessions: 2
security_ssh_ciphers:
  - chacha20-poly1305@openssh.com
  - aes256-gcm@openssh.com
  - aes128-gcm@openssh.com
security_ssh_kex_algorithms:
  - curve25519-sha256@libssh.org
  - diffie-hellman-group-exchange-sha256
security_ssh_macs:
  - hmac-sha2-512-etm@openssh.com
  - hmac-sha2-256-etm@openssh.com
```

### Firewall Configuration

By default, all servers are protected by UFW (Uncomplicated Firewall):

```yaml
# Firewall configuration
security_firewall_rules:
  - { port: 22, proto: tcp, rule: allow }
  - { port: 80, proto: tcp, rule: allow }
  - { port: 443, proto: tcp, rule: allow }
```

Additional ports are opened only as needed for specific services.

### Automatic Security Updates

Systems are configured to automatically install security updates:

```yaml
# Unattended upgrades configuration
common_unattended_upgrades_enabled: true
common_unattended_upgrade_origins:
  - "${distro_id}:${distro_codename}"
  - "${distro_id}:${distro_codename}-security"
common_unattended_upgrade_mail: "admin@example.com"
common_unattended_upgrade_automatic_reboot: true
```

### Kernel Hardening

The security role applies kernel-level hardening:

```yaml
# Kernel security parameters
security_kernel_parameters:
  - { name: "kernel.randomize_va_space", value: 2 }
  - { name: "net.ipv4.conf.all.accept_redirects", value: 0 }
  - { name: "net.ipv4.conf.all.accept_source_route", value: 0 }
  - { name: "net.ipv4.conf.all.log_martians", value: 1 }
  - { name: "net.ipv4.tcp_syncookies", value: 1 }
  - { name: "fs.protected_hardlinks", value: 1 }
  - { name: "fs.protected_symlinks", value: 1 }
```

### Fail2Ban Protection

Fail2ban is deployed to protect against brute force attempts:

```yaml
# Fail2ban configuration
- name: Configure Fail2ban
  ansible.builtin.copy:
    src: "{{ user_setup_fail2ban_config_src }}"
    dest: /etc/fail2ban/jail.local
    owner: root
    group: root
    mode: "0600"
```

## User Account Security

### Strong Password Policies

Password requirements are enforced system-wide:

```yaml
# Password policies
security_password_min_length: 12
security_password_min_complexity: 3 # Require 3 character classes
security_password_max_age: 90
security_password_history: 5
security_account_lockout_threshold: 5
security_account_lockout_time: 1800 # 30 minutes
```

### Secure User Setup

The user_setup role creates secure user accounts:

```yaml
# User configuration
- name: Create admin user
  ansible.builtin.user:
    name: "{{ root_setup_admin_user }}"
    shell: /bin/bash
    groups: sudo
    append: true
    create_home: true
    password: "{{ root_setup_password_hash }}"

# SSH key-based authentication
- name: Copy public key to authorized_keys
  ansible.posix.authorized_key:
    user: "{{ root_setup_admin_user }}"
    state: present
    key: "{{ lookup('template', 'public_key.j2') }}"
```

## Service Security

### Container Isolation

Docker services are deployed with security in mind:

```yaml
# Docker security settings
- name: Configure Docker daemon with secure defaults
  ansible.builtin.copy:
    dest: /etc/docker/daemon.json
    content: |
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        },
        "icc": false,
        "no-new-privileges": true,
        "userns-remap": "default",
        "live-restore": true
      }
    mode: "0644"
```

### TLS Everywhere

All services are configured to use TLS:

```yaml
# Traefik TLS configuration
traefik_command:
  - "--entrypoints.websecure.address=:443"
  - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
  - "--certificatesresolvers.myresolver.acme.email={{ traefik_acme_email }}"
  - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
```

### Secure Headers

Security-related HTTP headers are set:

```yaml
# Secure headers configuration
- "traefik.http.middlewares.secured-headers.headers.sslRedirect=true"
- "traefik.http.middlewares.secured-headers.headers.stsSeconds=31536000"
- "traefik.http.middlewares.secured-headers.headers.browserXssFilter=true"
- "traefik.http.middlewares.secured-headers.headers.contentTypeNosniff=true"
- "traefik.http.middlewares.secured-headers.headers.forceSTSHeader=true"
- "traefik.http.middlewares.secured-headers.headers.stsIncludeSubdomains=true"
- "traefik.http.middlewares.secured-headers.headers.stsPreload=true"
- "traefik.http.middlewares.secured-headers.headers.customFrameOptionsValue=SAMEORIGIN"
```

## Auditing and Monitoring

### System Auditing

The security role configures audit rules:

```yaml
# Auditing configuration
security_auditd_enabled: true
security_auditd_rules:
  - "-w /etc/passwd -p wa -k identity"
  - "-w /etc/group -p wa -k identity"
  - "-w /etc/shadow -p wa -k identity"
  - "-w /etc/sudoers -p wa -k identity"
  - "-a always,exit -F arch=b64 -S execve -k exec"
```

### File Integrity Monitoring

AIDE is deployed to detect unauthorized file changes:

```yaml
# File integrity monitoring
security_aide_enabled: true
security_aide_cron_schedule: "0 5 * * *" # Daily at 5am
security_aide_excluded_paths:
  - /var/log
  - /tmp
  - /var/tmp
```

### Central Logging

All logs are centralized for analysis:

```yaml
# Logging configuration in the logging role
filebeat:
  inputs:
    - type: log
      enabled: true
      paths:
        - /var/log/auth.log
        - /var/log/syslog
```

## Secret Management

### Encrypted Storage

All sensitive information is stored in encrypted vault files:

```bash
ansible-vault encrypt inventories/production/group_vars/vault.yml
```

### Password Rotation

Scripts facilitate regular password rotation:

```bash
./scripts/update-vault-pass.sh
```

### Separation of Secrets

Secrets are organized by environment and service:

```yaml
# Database credentials
vault_mailcow_dbpass: "secure_password"
vault_mailcow_dbroot: "secure_root_password"

# API keys and tokens
vault_monitoring_slack_webhook: "https://hooks.slack.com/services/..."
```

## Compliance Checks

The security role includes compliance validation against standards like CIS benchmarks:

```yaml
# CIS compliance checks
- name: Run CIS compliance checks
  block:
    - name: Check permissions on system files
      ansible.builtin.command: find /etc -type f -name "*.conf" -perm /o+w -ls
      register: world_writable_conf
      changed_when: false
      failed_when: world_writable_conf.stdout != ""
```

## Security Hardening Guide for Admins

1. **Regular Updates**: Run `make maintenance` regularly to keep systems updated
2. **Audit Logs**: Check `/var/log/audit/audit.log` for security events
3. **Firewall Rules**: Review firewall rules with `ufw status verbose`
4. **SSH Access**: Regularly rotate SSH keys for better security
5. **Monitoring Alerts**: Monitor security-related alerts in Grafana dashboards

## Security Incident Response

In case of security incidents:

1. **Isolate**: Disconnect affected systems from the network
2. **Analyze**: Use logging data to determine the extent of the breach
3. **Remediate**: Apply fixes to address the vulnerability
4. **Report**: Document the incident and notify relevant parties
5. **Prevent**: Update security measures to prevent similar incidents

By following these security practices, the SummitEthic infrastructure maintains a strong security posture aligned with industry best practices and ethical principles.
