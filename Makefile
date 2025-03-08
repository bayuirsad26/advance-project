.PHONY: install lint test deploy bootstrap security monitoring maintenance

# Variables
INVENTORY ?= production
TAGS ?= all
LIMIT ?= all

# Installation tasks
install:
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

# Linting
lint:
	ansible-lint
	yamllint .

# Molecule tests
test:
	cd molecule/default && molecule test

# Playbook execution
deploy:
	ansible-playbook -i inventories/$(INVENTORY)/inventory.yml playbooks/site.yml --tags=$(TAGS) --limit=$(LIMIT) --ask-vault-pass

bootstrap:
	ansible-playbook -i inventories/$(INVENTORY)/inventory.yml playbooks/bootstrap.yml --limit=$(LIMIT) --ask-vault-pass

security:
	ansible-playbook -i inventories/$(INVENTORY)/inventory.yml playbooks/security.yml --limit=$(LIMIT) --ask-vault-pass

monitoring:
	ansible-playbook -i inventories/$(INVENTORY)/inventory.yml playbooks/monitoring.yml --limit=$(LIMIT) --ask-vault-pass

maintenance:
	ansible-playbook -i inventories/$(INVENTORY)/inventory.yml playbooks/maintenance.yml --limit=$(LIMIT) --ask-vault-pass

# Utility functions
inventory-report:
	python3 scripts/inventory-report.py $(INVENTORY)

init-workspace:
	mkdir -p logs .ansible_facts_cache
	touch .vault_pass
	chmod 600 .vault_pass
	@echo "Remember to set your vault password in .vault_pass"