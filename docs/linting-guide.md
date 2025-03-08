# Ansible Linting Guide

This guide provides detailed instructions on how to meet the linting standards for the SummitEthic Ansible project and resolve common linting issues.

## Setting Up Linting Tools

### Install Required Tools

```bash
pip install ansible-lint yamllint
```

### Configure Linting Rules

The project includes configuration files for linting:

- `.ansible-lint` - Configuration for ansible-lint
- `.yamllint` - Configuration for YAML linting

Make sure these files exist and are properly configured:

**.ansible-lint**

```yaml
exclude_paths:
  - .github/
  - .cache/
  - tests/
  - molecule/
  - .ansible-lint
  - .yamllint

parseable: true
quiet: false
verbosity: 1

mock_modules: []
mock_roles: []

skip_list:
  - no-handler
  - no-changed-when
  - yaml_edit_module

warn_list:
  - yaml
  - experimental

use_default_rules: true

# Specific paths to ignore
ignore_paths:
  - monitoring.yml
  - security.yml
```

**.yamllint**

```yaml
---
extends: default

rules:
  line-length:
    max: 120
    level: warning
  truthy:
    allowed-values: ["true", "false", "yes", "no"]
  comments-indentation: false
  braces:
    max-spaces-inside: 1
  octal-values:
    forbid-implicit-octal: true
    forbid-explicit-octal: true
  comments:
    min-spaces-from-content: 1

ignore: |
  .github/
  molecule/
  collections/
  .ansible-lint
```

## Running Linting Checks

### Basic Linting

To lint the entire project:

```bash
ansible-lint
```

To lint specific files or directories:

```bash
ansible-lint playbooks/
ansible-lint roles/security/
```

### Verbose Output

For more detailed linting information:

```bash
ansible-lint -v
```

### Fixing Issues Automatically

Some issues can be fixed automatically:

```bash
ansible-lint --fix
```

## Common Linting Issues and Solutions

### 1. File Not Found Errors

**Error Message**:

```
load-failure[filenotfounderror]: [Errno 2] No such file or directory: '/path/to/monitoring.yml'
```

**Solution**:

1. Find where the file is referenced:

   ```bash
   grep -r "monitoring.yml" --include="*.yml" .
   ```

2. Create the file in the correct location:

   ```bash
   touch roles/mailcow/tasks/monitoring.yml
   ```

3. Add minimal content:
   ```yaml
   ---
   # Placeholder for monitoring tasks
   - name: Check if monitoring is enabled
     ansible.builtin.debug:
       msg: "Monitoring tasks not implemented yet"
     tags: [monitoring]
   ```

### 2. Line Length Issues

**Error Message**:

```
yaml[line-length]: Line too long (168 > 120 characters)
```

**Solutions**:

1. **For regular variables**, use YAML multi-line syntax:

   ```yaml
   # Before
   long_variable: "This is a very long text that exceeds the 120 character limit and causes linting warnings in the YAML file"

   # After (folded style)
   long_variable: >-
     This is a very long text that exceeds the 120 character limit
     and causes linting warnings in the YAML file
   ```

2. **For task parameters**, split them across multiple lines:

   ```yaml
   # Before
   - name: Long task
     ansible.builtin.copy:
       src: "files/very/long/path/to/source/file.txt"
       dest: "/very/long/path/to/destination/directory/with/very/long/file_name_that_makes_this_line_too_long.txt"
       mode: "0644"

   # After
   - name: Long task
     ansible.builtin.copy:
       src: "files/very/long/path/to/source/file.txt"
       dest: >-
         /very/long/path/to/destination/directory/with/
         very/long/file_name_that_makes_this_line_too_long.txt
       mode: "0644"
   ```

3. **For conditionals**, break up the logic:

   ```yaml
   # Before
   when: item.enabled == true and item.state == "present" and inventory_hostname in groups['web_servers'] and ansible_distribution == "Ubuntu"

   # After
   when:
     - item.enabled == true
     - item.state == "present"
     - inventory_hostname in groups['web_servers']
     - ansible_distribution == "Ubuntu"
   ```

### 3. YAML Formatting Issues

**Error Message**:

```
yaml[braces]: Too many spaces inside braces
```

**Solution**:

```yaml
# Incorrect
{ key1: value1, key2:  value2 }

# Correct
{key1: value1, key2: value2}
```

### 4. Module Name Errors

**Error Message**:

```
fqcn[canonical]: You should use canonical module name `community.general.archive` instead of `ansible.builtin.archive`
```

**Solution**: Use Fully Qualified Collection Names (FQCN):

```yaml
# Incorrect
- name: Archive files
  ansible.builtin.archive:
    path: /path/to/files
    dest: /path/to/archive.tgz

# Correct
- name: Archive files
  community.general.archive:
    path: /path/to/files
    dest: /path/to/archive.tgz
```

### 5. Comment Spacing Issues

**Error Message**:

```
yaml[comments]: Too few spaces before comment
```

**Solution**:

```yaml
# Incorrect
#This is a comment with no space
variable: value#This is also incorrect

# Correct
# This is a comment with space
variable: value  # This is also correct
```

### 6. Risky File Permissions

**Error Message**:

```
risky-file-permissions: File permissions unset or incorrect
```

**Solution**: Always set file permissions explicitly:

```yaml
# Incorrect
- name: Create file
  ansible.builtin.file:
    path: /path/to/file
    state: touch

# Correct
- name: Create file
  ansible.builtin.file:
    path: /path/to/file
    state: touch
    mode: "0644"
```

## Task Organization Best Practices

1. **Task Order**: Follow the recommended order for task parameters:

   ```yaml
   - name: Task name
     when: condition
     tags: [tag1, tag2]
     ansible.builtin.module:
       param1: value1
       param2: value2
     register: result
   ```

2. **Use Task Includes**: Break complex roles into separate files:

   ```yaml
   - name: Include security tasks
     ansible.builtin.import_tasks: security.yml
     tags: [security]
   ```

3. **Consistent Tagging**: Use consistent tags across the codebase:
   ```yaml
   tags: [role_name, function, environment]
   ```

## Advanced Linting

### Custom Linting Rules

You can create custom linting rules in `.ansible-lint`:

```yaml
custom_rules:
  role_name_match:
    description: "Role name should match directory name"
    match_files:
      - roles/*/meta/main.yml
    content_match: "'{{ role_path | basename }}'"
```

### Ignoring Specific Rules

To ignore specific rules for certain files, add comments:

```yaml
# noqa: rule1,rule2
- name: This task ignores specific rules
  ansible.builtin.debug:
    msg: "This will not trigger the ignored rules"
```

Remember that maintaining clean, linted code helps ensure consistency, readability, and reduces errors in our infrastructure code. Prioritize fixing linting issues rather than ignoring them.
