# Makefile for NexusCommerce Database Helm Chart
# Enhanced version with dynamic values support

.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean status logs connect template validate package

# Default values - can be overridden
ENVIRONMENT ?= dev
NAMESPACE ?= data
RELEASE_NAME ?= nexus-database
CHART_VERSION ?= 0.1.0
TIMEOUT ?= 15m

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Help target
help: ## Show this help message
	@echo "$(BLUE)NexusCommerce Database Helm Chart$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make <target> [ENVIRONMENT=<env>] [NAMESPACE=<ns>] [RELEASE_NAME=<name>]"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Environment Variables:$(NC)"
	@echo "  $(BLUE)ENVIRONMENT$(NC)   Target environment (dev|staging|prod) [default: $(ENVIRONMENT)]"
	@echo "  $(BLUE)NAMESPACE$(NC)     Kubernetes namespace [default: $(NAMESPACE)]"
	@echo "  $(BLUE)RELEASE_NAME$(NC)  Helm release name [default: $(RELEASE_NAME)]"
	@echo "  $(BLUE)TIMEOUT$(NC)       Installation timeout [default: $(TIMEOUT)]"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make dev                    # Deploy to development"
	@echo "  make prod NAMESPACE=data    # Deploy to production in 'data' namespace"
	@echo "  make upgrade ENVIRONMENT=staging  # Upgrade staging deployment"
	@echo "  make template ENVIRONMENT=prod    # Generate production templates"

# Validation targets
validate-env: ## Validate environment parameter
	@if [ "$(ENVIRONMENT)" != "dev" ] && [ "$(ENVIRONMENT)" != "staging" ] && [ "$(ENVIRONMENT)" != "prod" ]; then \
		echo "$(RED)Error: ENVIRONMENT must be one of: dev, staging, prod$(NC)"; \
		exit 1; \
	fi

check-tools: ## Check required tools are installed
	@echo "$(BLUE)Checking required tools...$(NC)"
	@command -v helm >/dev/null 2>&1 || { echo "$(RED)Error: helm is not installed$(NC)"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "$(RED)Error: kubectl is not installed$(NC)"; exit 1; }
	@kubectl cluster-info >/dev/null 2>&1 || { echo "$(RED)Error: kubectl is not configured or cluster is not reachable$(NC)"; exit 1; }
	@echo "$(GREEN)✅ All required tools are available$(NC)"

# Core deployment targets
install: validate-env check-tools ## Install the chart (ENV=dev|staging|prod)
	@echo "$(BLUE)Installing nexus-database for $(ENVIRONMENT) environment...$(NC)"
	@if [ -f "./deploy.sh" ]; then \
		./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME); \
	else \
		helm install $(RELEASE_NAME) . \
			-f values-$(ENVIRONMENT).yaml \
			--namespace $(NAMESPACE) \
			--create-namespace \
			--timeout $(TIMEOUT) \
			--wait; \
	fi
	@echo "$(GREEN)✅ Installation completed for $(ENVIRONMENT)$(NC)"

upgrade: validate-env check-tools ## Upgrade existing release (ENV=dev|staging|prod)
	@echo "$(BLUE)Upgrading nexus-database for $(ENVIRONMENT) environment...$(NC)"
	@if [ -f "./deploy.sh" ]; then \
		./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade; \
	else \
		helm upgrade $(RELEASE_NAME) . \
			-f values-$(ENVIRONMENT).yaml \
			--namespace $(NAMESPACE) \
			--timeout $(TIMEOUT) \
			--wait; \
	fi
	@echo "$(GREEN)✅ Upgrade completed for $(ENVIRONMENT)$(NC)"

uninstall: ## Uninstall the chart
	@echo "$(BLUE)Uninstalling nexus-database...$(NC)"
	@if [ -f "./undeploy.sh" ]; then \
		./undeploy.sh -n $(NAMESPACE) -r $(RELEASE_NAME); \
	else \
		helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE) || true; \
		kubectl delete pvc --all -n $(NAMESPACE) 2>/dev/null || true; \
	fi
	@echo "$(GREEN)✅ Uninstallation completed$(NC)"

# Environment-specific shortcuts
dev: ## Deploy to development environment
	@$(MAKE) install ENVIRONMENT=dev

staging: ## Deploy to staging environment
	@$(MAKE) install ENVIRONMENT=staging

prod: ## Deploy to production environment
	@$(MAKE) install ENVIRONMENT=prod

# Testing and validation targets
dry-run: validate-env ## Perform a dry run (ENV=dev|staging|prod)
	@echo "$(BLUE)Dry run for $(ENVIRONMENT) environment...$(NC)"
	@if [ -f "./deploy.sh" ]; then \
		./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --dry-run; \
	else \
		helm install $(RELEASE_NAME) . \
			-f values-$(ENVIRONMENT).yaml \
			--namespace $(NAMESPACE) \
			--dry-run --debug; \
	fi

template: validate-env ## Generate Kubernetes manifests (ENV=dev|staging|prod)
	@echo "$(BLUE)Generating templates for $(ENVIRONMENT) environment...$(NC)"
	@helm template $(RELEASE_NAME) . \
		-f values-$(ENVIRONMENT).yaml \
		--namespace $(NAMESPACE) \
		--debug

template-all: ## Generate templates for all environments
	@echo "$(BLUE)Generating templates for all environments...$(NC)"
	@echo "$(YELLOW)Development templates:$(NC)"
	@helm template $(RELEASE_NAME) . -f values-dev.yaml --namespace $(NAMESPACE) > templates-dev.yaml
	@echo "$(YELLOW)Staging templates:$(NC)"
	@helm template $(RELEASE_NAME) . -f values-staging.yaml --namespace $(NAMESPACE) > templates-staging.yaml
	@echo "$(YELLOW)Production templates:$(NC)"
	@helm template $(RELEASE_NAME) . -f values-prod.yaml --namespace $(NAMESPACE) > templates-prod.yaml
	@echo "$(GREEN)✅ Templates generated: templates-dev.yaml, templates-staging.yaml, templates-prod.yaml$(NC)"

lint: ## Lint the helm chart
	@echo "$(BLUE)Linting helm chart...$(NC)"
	@helm lint . || (echo "$(RED)❌ Helm lint failed$(NC)" && exit 1)
	@helm lint . -f values-dev.yaml || (echo "$(RED)❌ Helm lint failed for dev values$(NC)" && exit 1)
	@helm lint . -f values-staging.yaml || (echo "$(RED)❌ Helm lint failed for staging values$(NC)" && exit 1)
	@helm lint . -f values-prod.yaml || (echo "$(RED)❌ Helm lint failed for prod values$(NC)" && exit 1)
	@echo "$(GREEN)✅ Helm chart lint passed$(NC)"

test: ## Test the helm chart rendering
	@echo "$(BLUE)Testing helm chart...$(NC)"
	@helm template $(RELEASE_NAME) . -f values-dev.yaml --debug >/dev/null || (echo "$(RED)❌ Template rendering failed for dev$(NC)" && exit 1)
	@helm template $(RELEASE_NAME) . -f values-staging.yaml --debug >/dev/null || (echo "$(RED)❌ Template rendering failed for staging$(NC)" && exit 1)
	@helm template $(RELEASE_NAME) . -f values-prod.yaml --debug >/dev/null || (echo "$(RED)❌ Template rendering failed for prod$(NC)" && exit 1)
	@echo "$(GREEN)✅ Template rendering tests passed$(NC)"

validate: lint test ## Run all validation checks
	@echo "$(GREEN)✅ All validation checks passed$(NC)"

# Package and dependency management
package: lint ## Package the helm chart
	@echo "$(BLUE)Packaging helm chart...$(NC)"
	@helm package . --version $(CHART_VERSION)
	@echo "$(GREEN)✅ Chart packaged: nexus-database-$(CHART_VERSION).tgz$(NC)"

dependencies: ## Update chart dependencies
	@echo "$(BLUE)Updating chart dependencies...$(NC)"
	@helm dependency update
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

# Operational targets
status: ## Show deployment status
	@echo "$(BLUE)Checking deployment status...$(NC)"
	@echo "$(YELLOW)Helm releases in namespace '$(NAMESPACE)':$(NC)"
	@helm list -n $(NAMESPACE) || true
	@echo ""
	@echo "$(YELLOW)Kubernetes resources in namespace '$(NAMESPACE)':$(NC)"
	@kubectl get all -n $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)No resources found or namespace doesn't exist$(NC)"
	@echo ""
	@echo "$(YELLOW)Persistent Volume Claims:$(NC)"
	@kubectl get pvc -n $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)No PVCs found$(NC)"

logs: ## Show logs for all database pods
	@echo "$(BLUE)Showing logs for database pods...$(NC)"
	@echo "$(YELLOW)MongoDB Cart logs:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l app=cart-mongodb --tail=50 --since=5m 2>/dev/null || echo "$(YELLOW)No cart-mongodb pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)MongoDB User logs:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l app=user-mongodb --tail=50 --since=5m 2>/dev/null || echo "$(YELLOW)No user-mongodb pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)PostgreSQL logs:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l tier=database,database-type=postgresql --tail=50 --since=5m 2>/dev/null || echo "$(YELLOW)No PostgreSQL pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)Redis logs:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l app=redis-service --tail=50 --since=5m 2>/dev/null || echo "$(YELLOW)No Redis pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)Kafka logs:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l app=kafka --tail=50 --since=5m 2>/dev/null || echo "$(YELLOW)No Kafka pods found$(NC)"

logs-follow: ## Follow logs for all database pods
	@echo "$(BLUE)Following logs for database pods (Ctrl+C to stop)...$(NC)"
	@kubectl logs -n $(NAMESPACE) -l tier=database --tail=10 -f

connect: ## Show connection information
	@echo "$(BLUE)=== Database Connection Information ===$(NC)"
	@echo ""
	@echo "$(YELLOW)MongoDB Connections:$(NC)"
	@echo "  $(GREEN)Cart Service:$(NC) mongodb://cart-mongodb-headless.$(NAMESPACE).svc.cluster.local:27017/cartdb"
	@echo "  $(GREEN)User Service:$(NC) mongodb://user-mongodb-headless.$(NAMESPACE).svc.cluster.local:27017/userdb"
	@echo ""
	@echo "$(YELLOW)PostgreSQL Connections:$(NC)"
	@echo "  $(GREEN)Product Service:$(NC) product-postgres-service.$(NAMESPACE).svc.cluster.local:5432/productdb"
	@echo "  $(GREEN)Payment Service:$(NC) payment-postgres-service.$(NAMESPACE).svc.cluster.local:5432/paymentdb"
	@echo "  $(GREEN)Order Service:$(NC) order-postgres-service.$(NAMESPACE).svc.cluster.local:5432/orderdb"
	@echo "  $(GREEN)Loyalty Service:$(NC) loyalty-postgres-service.$(NAMESPACE).svc.cluster.local:5432/loyalty-service"
	@echo "  $(GREEN)Shipping Service:$(NC) shipping-postgres-service.$(NAMESPACE).svc.cluster.local:5432/shippingdb"
	@echo ""
	@echo "$(YELLOW)Cache & Messaging:$(NC)"
	@echo "  $(GREEN)Redis:$(NC) redis-service.$(NAMESPACE).svc.cluster.local:6379"
	@echo "  $(GREEN)Kafka:$(NC) kafka-service.$(NAMESPACE).svc.cluster.local:9092"
	@echo ""
	@echo "$(YELLOW)Credentials:$(NC)"
	@echo "  Check secrets in namespace '$(NAMESPACE)': kubectl get secrets -n $(NAMESPACE)"

# Debugging and troubleshooting
debug: ## Debug pod issues
	@echo "$(BLUE)Debugging deployment issues...$(NC)"
	@echo "$(YELLOW)Pod status:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -o wide 2>/dev/null || echo "$(YELLOW)No pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)Recent events:$(NC)"
	@kubectl get events -n $(NAMESPACE) --sort-by='.lastTimestamp' --field-selector type=Warning 2>/dev/null || true
	@echo ""
	@echo "$(YELLOW)Persistent Volume status:$(NC)"
	@kubectl get pv | grep $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)No PVs found for namespace$(NC)"

describe: ## Describe failed pods
	@echo "$(BLUE)Describing failed or pending pods...$(NC)"
	@kubectl get pods -n $(NAMESPACE) --field-selector=status.phase!=Running,status.phase!=Succeeded -o name 2>/dev/null | while read pod; do \
		echo "$(YELLOW)Describing $$pod:$(NC)"; \
		kubectl describe -n $(NAMESPACE) $$pod; \
		echo ""; \
	done || echo "$(GREEN)No failed pods found$(NC)"

restart: ## Restart all deployments
	@echo "$(BLUE)Restarting all deployments...$(NC)"
	@kubectl rollout restart deployment -n $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)No deployments found$(NC)"
	@kubectl rollout restart statefulset -n $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)No statefulsets found$(NC)"
	@echo "$(GREEN)✅ Restart initiated$(NC)"

# Environment management
clean: ## Clean up development environment
	@$(MAKE) uninstall ENVIRONMENT=dev

clean-all: ## Clean up all environments (DANGEROUS!)
	@echo "$(RED)⚠️  This will clean up ALL environments!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) uninstall ENVIRONMENT=dev NAMESPACE=data || true
	@$(MAKE) uninstall ENVIRONMENT=staging NAMESPACE=data || true
	@$(MAKE) uninstall ENVIRONMENT=prod NAMESPACE=data || true
	@echo "$(GREEN)✅ All environments cleaned$(NC)"

reset-dev: clean dev ## Reset development environment (clean + install)

# Monitoring and health checks
health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo "$(YELLOW)Checking MongoDB health:$(NC)"
	@kubectl exec -n $(NAMESPACE) -it $$(kubectl get pods -n $(NAMESPACE) -l app=cart-mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -- mongosh --eval "db.adminCommand('ping')" 2>/dev/null || echo "$(RED)MongoDB not accessible$(NC)"
	@echo "$(YELLOW)Checking PostgreSQL health:$(NC)"
	@kubectl exec -n $(NAMESPACE) -it $$(kubectl get pods -n $(NAMESPACE) -l app=product-postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -- pg_isready 2>/dev/null || echo "$(RED)PostgreSQL not accessible$(NC)"
	@echo "$(YELLOW)Checking Redis health:$(NC)"
	@kubectl exec -n $(NAMESPACE) -it $$(kubectl get pods -n $(NAMESPACE) -l app=redis-service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) -- redis-cli ping 2>/dev/null || echo "$(RED)Redis not accessible$(NC)"

port-forward: ## Set up port forwarding for local access
	@echo "$(BLUE)Setting up port forwarding...$(NC)"
	@echo "$(YELLOW)Access services locally:$(NC)"
	@echo "  MongoDB Cart: kubectl port-forward -n $(NAMESPACE) svc/cart-mongodb-headless 27017:27017 &"
	@echo "  PostgreSQL Product: kubectl port-forward -n $(NAMESPACE) svc/product-postgres-service 5432:5432 &"
	@echo "  Redis: kubectl port-forward -n $(NAMESPACE) svc/redis-service 6379:6379 &"
	@echo "  Kafka: kubectl port-forward -n $(NAMESPACE) svc/kafka-service 9092:9092 &"
	@echo ""
	@echo "$(YELLOW)Starting port-forward for Redis (Ctrl+C to stop):$(NC)"
	@kubectl port-forward -n $(NAMESPACE) svc/redis-service 6379:6379

# Chart development
update-deps: ## Update and check dependencies
	@echo "$(BLUE)Updating chart dependencies...$(NC)"
	@helm dependency update
	@helm dependency build
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

release: validate package ## Prepare a release (validate + package)
	@echo "$(GREEN)✅ Release $(CHART_VERSION) is ready$(NC)"

# Documentation
docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@helm-docs . || echo "$(YELLOW)helm-docs not installed, skipping documentation generation$(NC)"

# Quick actions
quick-dev: check-tools ## Quick development deployment (skip validation)
	@helm upgrade --install $(RELEASE_NAME) . -f values-dev.yaml --namespace $(NAMESPACE) --create-namespace

watch: ## Watch pod status
	@echo "$(BLUE)Watching pod status (Ctrl+C to stop)...$(NC)"
	@watch kubectl get pods -n $(NAMESPACE)

# Backup operations (if backup is enabled)
backup-now: ## Trigger immediate backup (if backup CronJob exists)
	@echo "$(BLUE)Triggering immediate backup...$(NC)"
	@kubectl create job -n $(NAMESPACE) manual-backup-$$(date +%s) --from=cronjob/backup-cronjob 2>/dev/null || echo "$(YELLOW)No backup CronJob found$(NC)"

# Show current configuration
config: ## Show current configuration
	@echo "$(BLUE)Current Configuration:$(NC)"
	@echo "  $(YELLOW)Environment:$(NC) $(ENVIRONMENT)"
	@echo "  $(YELLOW)Namespace:$(NC) $(NAMESPACE)"
	@echo "  $(YELLOW)Release Name:$(NC) $(RELEASE_NAME)"
	@echo "  $(YELLOW)Chart Version:$(NC) $(CHART_VERSION)"
	@echo "  $(YELLOW)Timeout:$(NC) $(TIMEOUT)"
	@echo ""
	@echo "$(BLUE)Values File:$(NC) values-$(ENVIRONMENT).yaml"
	@echo "$(BLUE)Current Context:$(NC) $$(kubectl config current-context 2>/dev/null || echo 'Not set')"

# Default target
.DEFAULT_GOAL := help