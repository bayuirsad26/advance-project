#!/usr/bin/env python3

"""
SummitEthic Ansible Inventory Report Generator
This script generates a report of the current inventory, showing hosts, groups, and variables
"""

import argparse
import os
import sys
import yaml

try:
    from prettytable import PrettyTable
except ImportError:
    print("Error: The 'prettytable' package is not installed.")
    print("Please install it using: pip install prettytable")
    sys.exit(1)

# Parse arguments
parser = argparse.ArgumentParser(description='Generate a report of the Ansible inventory')
parser.add_argument('inventory', nargs='?', default='production', 
                    help='The inventory to report on (default: production)')
parser.add_argument('--detail', '-d', action='store_true',
                    help='Include detailed variable information')
args = parser.parse_args()

# Set up paths
inventory_path = f"inventories/{args.inventory}/inventory.yml"
group_vars_path = f"inventories/{args.inventory}/group_vars"
host_vars_path = f"inventories/{args.inventory}/host_vars"

# Check if inventory exists
if not os.path.exists(inventory_path):
    print(f"Error: Inventory file {inventory_path} not found")
    print(f"Available inventories:")
    for inv in os.listdir("inventories"):
        if os.path.exists(f"inventories/{inv}/inventory.yml"):
            print(f"  - {inv}")
    sys.exit(1)

# Load inventory
try:
    with open(inventory_path, 'r') as f:
        inventory = yaml.safe_load(f)
except Exception as e:
    print(f"Error loading inventory file: {e}")
    sys.exit(1)

# Extract hosts and groups
hosts = {}
groups = {}

if 'all' in inventory:
    if 'hosts' in inventory['all']:
        for host, host_vars in inventory['all']['hosts'].items():
            hosts[host] = host_vars or {}
            hosts[host]['groups'] = ['all']
    
    if 'children' in inventory['all']:
        for group, group_data in inventory['all']['children'].items():
            groups[group] = {'hosts': [], 'vars': {}}
            if 'hosts' in group_data:
                for host, host_vars in group_data['hosts'].items():
                    if host not in hosts:
                        hosts[host] = host_vars or {}
                        hosts[host]['groups'] = [group]
                    else:
                        hosts[host]['groups'].append(group)
                        groups[group]['hosts'].append(host)
            if 'vars' in group_data:
                groups[group]['vars'] = group_data['vars']

# Load group variables from files
if os.path.exists(group_vars_path):
    for item in os.listdir(group_vars_path):
        item_path = os.path.join(group_vars_path, item)
        if os.path.isdir(item_path):  # Handle split group vars
            group_name = item
            combined_vars = {}
            for var_file in os.listdir(item_path):
                if var_file.endswith(('.yml', '.yaml')):
                    try:
                        with open(os.path.join(item_path, var_file), 'r') as f:
                            file_vars = yaml.safe_load(f) or {}
                            combined_vars.update(file_vars)
                    except Exception as e:
                        print(f"Warning: Error loading {item_path}/{var_file}: {e}")
            if group_name in groups:
                groups[group_name]['vars'].update(combined_vars)
        elif item.endswith(('.yml', '.yaml')) and item != 'vault.yml':
            group_name = item.split('.')[0]
            try:
                with open(item_path, 'r') as f:
                    group_vars = yaml.safe_load(f) or {}
                    if group_name in groups:
                        groups[group_name]['vars'].update(group_vars)
            except Exception as e:
                print(f"Warning: Error loading {item_path}: {e}")

# Load host variables
if os.path.exists(host_vars_path):
    for item in os.listdir(host_vars_path):
        if item.endswith(('.yml', '.yaml')):
            host_name = item.split('.')[0]
            try:
                with open(os.path.join(host_vars_path, item), 'r') as f:
                    host_vars = yaml.safe_load(f) or {}
                    if host_name in hosts:
                        hosts[host_name].update(host_vars)
            except Exception as e:
                print(f"Warning: Error loading {host_vars_path}/{item}: {e}")

# Print report
print(f"\n{'=' * 80}")
print(f"ANSIBLE INVENTORY REPORT: {args.inventory.upper()}")
print(f"{'=' * 80}\n")

# Host summary
host_table = PrettyTable()
host_table.field_names = ["Hostname", "IP", "Groups", "Variables"]
host_table.align["Hostname"] = "l"
host_table.align["IP"] = "l"
host_table.align["Groups"] = "l"
host_table.align["Variables"] = "l"

for host, host_data in sorted(hosts.items()):
    ip = host_data.get('ansible_host', 'N/A')
    groups_list = ', '.join(host_data.get('groups', []))
    
    # Count variables (excluding certain keys)
    var_count = sum(1 for k in host_data.keys() if k not in ['groups', 'ansible_host'])
    var_text = f"{var_count} variables"
    
    if args.detail and var_count > 0:
        var_text += ":"
        for k, v in sorted(host_data.items()):
            if k not in ['groups', 'ansible_host']:
                if isinstance(v, (dict, list)):
                    var_text += f"\n  - {k}: [complex]"
                else:
                    var_value = str(v)
                    if len(var_value) > 30:
                        var_value = var_value[:27] + "..."
                    var_text += f"\n  - {k}: {var_value}"
    
    host_table.add_row([host, ip, groups_list, var_text])

print("HOST INVENTORY")
print(host_table)
print()

# Group summary
group_table = PrettyTable()
group_table.field_names = ["Group", "Hosts", "Variables"]
group_table.align["Group"] = "l"
group_table.align["Hosts"] = "l"
group_table.align["Variables"] = "l"

for group, group_data in sorted(groups.items()):
    hosts_count = len(group_data.get('hosts', []))
    hosts_list = ', '.join(group_data.get('hosts', []))
    if len(hosts_list) > 60:
        hosts_list = hosts_list[:57] + "..."
    
    var_count = len(group_data.get('vars', {}))
    var_text = f"{var_count} variables"
    
    if args.detail and var_count > 0:
        var_text += ":"
        for k, v in sorted(group_data.get('vars', {}).items()):
            if isinstance(v, (dict, list)):
                var_text += f"\n  - {k}: [complex]"
            else:
                var_value = str(v)
                if len(var_value) > 30:
                    var_value = var_value[:27] + "..."
                var_text += f"\n  - {k}: {var_value}"
    
    group_table.add_row([group, f"{hosts_count} hosts:\n{hosts_list}", var_text])

print("GROUP INVENTORY")
print(group_table)

# Summary
print("\nSUMMARY")
print(f"Total hosts: {len(hosts)}")
print(f"Total groups: {len(groups)}")

if args.detail:
    print("\nINVENTORY STRUCTURE")
    for group, group_data in sorted(groups.items()):
        print(f"- {group}")
        for host in sorted(group_data.get('hosts', [])):
            print(f"  - {host}")

print(f"\n{'=' * 80}")
print(f"Report generated for inventory: {args.inventory}")
print(f"{'=' * 80}\n")