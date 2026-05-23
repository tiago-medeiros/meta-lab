# meta-lab: Master Makefile para o Platform Engineering Lab
# Orquestra todos os domínios com interfaces padronizadas.

export LAB_ROOT ?= $(shell pwd)

SUBDOMAINS = lab-infra lab-k8s lab-observability lab-messaging lab-gitops
SUBDOMAIN_TARGETS = $(SUBDOMAINS:%=%.target)

# Default target shows help
.DEFAULT: help
help:
	@echo "Platform Engineering Lab - Orquestrador"
	@echo ""
	@echo "Domínios disponíveis:"
	@grep -E '^[a-z].*:' Makefile | grep -v 'help:' | sed 's/:$$//' | awk '{printf "  %-20s %s\n", $$1, substr($$0, index($$0, "##"))}'
	@echo ""
	@echo "Comandos:"
	@echo "  all-up               Inicia todos os domínios"
	@echo "  all-down             Para todos os domínios"
	@echo "  all-status           Status de todos os domínios"
	@echo "  all-validate         Validação de todos os domínios"
	@echo "  <domain> <target>   Executa target em domínio específico"
	@echo ""
	@echo "Exemplo:"
	@echo "  make lab-infra setup"
	@echo "  make lab-k8s deploy"

# Generate targets for each domain
$(SUBDOMAIN_TARGETS):
	@$(MAKE) -C $(@D) $(@F)

# Global commands
.PHONY: all-up all-down all-status all-validate help $(SUBDOMAINS)

all-up:
	@echo "Starting all domains..."
	@for domain in $(SUBDOMAINS); do \
		echo "==> $$domain setup"; \
		$(MAKE) -C $$domain setup; \
		$(MAKE) -C $$domain deploy; \
	done
	@echo "All domains started."

all-down:
	@echo "Stopping all domains..."
	@for domain in $(SUBDOMAINS); do \
		echo "==> $$domain teardown"; \
		$(MAKE) -C $$domain teardown; \
	done
	@echo "All domains stopped."

all-status:
	@echo "Checking all domains..."
	@for domain in $(SUBDOMAINS); do \
		echo "==> $$domain"; \
		$(MAKE) -C $$domain test; \
		echo ""; \
	done

all-validate:
	@echo "Validating all domains..."
	@for domain in $(SUBDOMAINS); do \
		echo "==> $$domain"; \
		$(MAKE) -C $$domain validate; \
		echo ""; \
	done

# Domain aliases (run both setup and deploy for a domain)
.PHONY: $(SUBDOMAINS)
$(SUBDOMAINS):
	@$(MAKE) -C $@ setup
	@$(MAKE) -C $@ deploy
