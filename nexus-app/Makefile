# NexusCommerce Complete Platform Makefile
.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean status

# Default values
ENVIRONMENT ?= dev
NAMESPACE ?= nexus-commerce
RELEASE_NAME ?= nexus-commerce
CHART_VERSION ?= 1.0.0

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
PURPLE := \033[0;35m
NC := \033[0m

help: ## Show this help message
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    NexusCommerce Complete E-commerce Platform$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Environment Examples:$(NC)"
	@echo "  $(GREEN)make dev$(NC)                    # Deploy complete development environment"
	@echo "  $(GREEN)make staging$(NC)                # Deploy staging environment"
	@echo "  $(GREEN)make prod$(NC)                   # Deploy production environment"
	@echo "  $(GREEN)make status ENVIRONMENT=dev$(NC) # Check development status"

# =============================================================================
# MAIN DEPLOYMENT COMMANDS
# =============================================================================

install: ## Install the complete platform (ENV=dev|staging|prod)
	@echo "$(BLUE)Installing NexusCommerce Platform for $(ENVIRONMENT) environment...$(NC)"
	@echo "$(YELLOW)This will deploy all components: Database → Infrastructure → Microservices → Observability → Tools$(NC)"
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME)

upgrade: ## Upgrade existing platform (ENV=dev|staging|prod)
	@echo "$(BLUE)Upgrading NexusCommerce Platform for $(ENVIRONMENT) environment...$(NC)"
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade

uninstall: ## Uninstall the complete platform
	@echo "$(RED)Uninstalling NexusCommerce Platform...$(NC)"
	./undeploy.sh -n $(NAMESPACE) -r $(RELEASE_NAME)

dry-run: ## Perform a dry run (ENV=dev|staging|prod)
	@echo "$(YELLOW)Dry run for $(ENVIRONMENT) environment...$(NC)"
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --dry-run

lint: ## Lint all helm charts
	@echo "$(BLUE)Linting umbrella chart...$(NC)"
	helm lint .
	@echo "$(BLUE)Linting sub-charts...$(NC)"
	@for chart in charts/*/; do \
		if [ -d "$$chart" ]; then \
			echo "Linting $$chart"; \
			helm lint "$$chart" || exit 1; \
		fi \
	done

test: ## Test all helm charts
	@echo "$(BLUE)Testing helm charts...$(NC)"
	helm template $(RELEASE_NAME) . -f values-dev.yaml --debug

# =============================================================================
# ENVIRONMENT-SPECIFIC DEPLOYMENTS
# =============================================================================

dev: ## Deploy complete development environment
	@echo "$(GREEN)🚀 Deploying NexusCommerce Development Environment$(NC)"
	$(MAKE) install ENVIRONMENT=dev

staging: ## Deploy staging environment
	@echo "$(GREEN)🚀 Deploying NexusCommerce Staging Environment$(NC)"
	$(MAKE) install ENVIRONMENT=staging

prod: ## Deploy production environment
	@echo "$(GREEN)🚀 Deploying NexusCommerce Production Environment$(NC)"
	$(MAKE) install ENVIRONMENT=prod

clean: ## Clean up development environment
	@echo "$(YELLOW)Cleaning up development environment...$(NC)"
	$(MAKE) uninstall ENVIRONMENT=dev

# =============================================================================
# STATUS AND MONITORING
# =============================================================================

status: ## Show complete platform status
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    NexusCommerce Platform Status$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Helm Releases:$(NC)"
	@helm list -n $(NAMESPACE) || echo "$(RED)No releases found$(NC)"
	@echo ""
	@echo "$(YELLOW)All Resources:$(NC)"
	@kubectl get all -n $(NAMESPACE) --show-labels || echo "$(RED)Namespace not found$(NC)"
	@echo ""
	@echo "$(YELLOW)Persistent Volumes:$(NC)"
	@kubectl get pvc -n $(NAMESPACE) || echo "$(RED)No PVCs found$(NC)"
	@echo ""
	@echo "$(YELLOW)Ingress Resources:$(NC)"
	@kubectl get ingress -n $(NAMESPACE) || echo "$(RED)No ingress found$(NC)"

health: ## Check health of all platform components
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    Platform Health Check$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)📊 Database Layer:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=data -o wide 2>/dev/null || echo "$(RED)No data pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)🏗️  Infrastructure Layer:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=infrastructure -o wide 2>/dev/null || echo "$(RED)No infrastructure pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)🔧 Microservices Layer:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=backend -o wide 2>/dev/null || echo "$(RED)No microservice pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)📈 Observability Layer:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=monitoring -o wide 2>/dev/null || echo "$(RED)No monitoring pods found$(NC)"
	@echo ""
	@echo "$(YELLOW)🛠️  Tools Layer:$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=tools -o wide 2>/dev/null || echo "$(RED)No tools pods found$(NC)"

logs: ## Show logs for all platform components
	@echo "$(BLUE)Showing recent logs for all components...$(NC)"
	@echo "$(YELLOW)Database Layer:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l tier=data --tail=20 --max-log-requests=10 2>/dev/null || true
	@echo "$(YELLOW)Infrastructure Layer:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l tier=infrastructure --tail=20 --max-log-requests=10 2>/dev/null || true
	@echo "$(YELLOW)Microservices Layer:$(NC)"
	@kubectl logs -n $(NAMESPACE) -l tier=backend --tail=20 --max-log-requests=10 2>/dev/null || true

# =============================================================================
# SERVICE-SPECIFIC COMMANDS
# =============================================================================

logs-user: ## Show user service logs
	@kubectl logs -n $(NAMESPACE) -l app=user-service -f --tail=100

logs-product: ## Show product service logs
	@kubectl logs -n $(NAMESPACE) -l app=product-service -f --tail=100

logs-cart: ## Show cart service logs
	@kubectl logs -n $(NAMESPACE) -l app=cart-service -f --tail=100

logs-order: ## Show order service logs
	@kubectl logs -n $(NAMESPACE) -l app=order-service -f --tail=100

logs-payment: ## Show payment service logs
	@kubectl logs -n $(NAMESPACE) -l app=payment-service -f --tail=100

logs-notification: ## Show notification service logs
	@kubectl logs -n $(NAMESPACE) -l app=notification-service -f --tail=100

logs-loyalty: ## Show loyalty service logs
	@kubectl logs -n $(NAMESPACE) -l app=loyalty-service -f --tail=100

logs-shipping: ## Show shipping service logs
	@kubectl logs -n $(NAMESPACE) -l app=shipping-service -f --tail=100

# =============================================================================
# ACCESS AND CONNECTIVITY
# =============================================================================

connect: ## Show connection information for all services
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    NexusCommerce Connection Information$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)🌐 Main API Gateway:$(NC)"
	@echo "  Internal: http://api-gateway.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  External: Check ingress configuration"
	@echo ""
	@echo "$(YELLOW)🔧 Microservices (Internal URLs):$(NC)"
	@echo "  User Service: http://user-service.$(NAMESPACE).svc.cluster.local:8081"
	@echo "  Product Service: http://product-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Cart Service: http://cart-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Order Service: http://order-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Payment Service: http://payment-service.$(NAMESPACE).svc.cluster.local:8084"
	@echo "  Notification Service: http://notification-service.$(NAMESPACE).svc.cluster.local:8086"
	@echo "  Loyalty Service: http://loyalty-service.$(NAMESPACE).svc.cluster.local:8084"
	@echo "  Shipping Service: http://shipping-service.$(NAMESPACE).svc.cluster.local:8085"
	@echo ""
	@echo "$(YELLOW)📊 Monitoring & Tools:$(NC)"
	@echo "  Grafana: http://grafana.$(NAMESPACE).svc.cluster.local:3000"
	@echo "  Prometheus: http://prometheus.$(NAMESPACE).svc.cluster.local:9090"
	@echo "  Kafka UI: http://kafka-ui.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  Adminer: http://adminer.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  pgAdmin: http://pgadmin.$(NAMESPACE).svc.cluster.local:80"
	@echo ""
	@echo "$(YELLOW)🏥 Health Check URLs:$(NC)"
	@echo "  User: http://user-service.$(NAMESPACE).svc.cluster.local:8081/api/users/actuator/health"
	@echo "  Product: http://product-service.$(NAMESPACE).svc.cluster.local:8082/api/products/actuator/health"
	@echo "  Cart: http://cart-service.$(NAMESPACE).svc.cluster.local:8082/api/carts/actuator/health"
	@echo "  Order: http://order-service.$(NAMESPACE).svc.cluster.local:8082/actuator/health"
	@echo "  Payment: http://payment-service.$(NAMESPACE).svc.cluster.local:8084/health"

port-forward: ## Set up port forwarding for local development access
	@echo "$(BLUE)Setting up port forwarding for local access...$(NC)"
	@echo "$(YELLOW)Available endpoints:$(NC)"
	@echo "  API Gateway: http://localhost:8080"
	@echo "  Grafana: http://localhost:3000 (admin/admin123)"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Kafka UI: http://localhost:8081"
	@echo "  Adminer: http://localhost:8082"
	@echo "  pgAdmin: http://localhost:8083"
	@echo ""
	@echo "$(YELLOW)Press Ctrl+C to stop port forwarding$(NC)"
	@kubectl port-forward -n $(NAMESPACE) svc/api-gateway 8080:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/grafana 3000:3000 &
	@kubectl port-forward -n $(NAMESPACE) svc/prometheus 9090:9090 &
	@kubectl port-forward -n $(NAMESPACE) svc/kafka-ui 8081:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/adminer 8082:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/pgadmin 8083:80 &
	@wait

# =============================================================================
# OPERATIONS AND MAINTENANCE
# =============================================================================

restart: ## Restart all platform deployments
	@echo "$(BLUE)Restarting all platform deployments...$(NC)"
	@kubectl rollout restart deployment -n $(NAMESPACE)
	@kubectl rollout status deployment -n $(NAMESPACE) --timeout=600s

restart-microservices: ## Restart only microservices
	@echo "$(BLUE)Restarting microservices...$(NC)"
	@kubectl rollout restart deployment -n $(NAMESPACE) -l tier=backend
	@kubectl rollout status deployment -n $(NAMESPACE) -l tier=backend --timeout=300s

restart-infrastructure: ## Restart infrastructure services
	@echo "$(BLUE)Restarting infrastructure...$(NC)"
	@kubectl rollout restart deployment -n $(NAMESPACE) -l tier=infrastructure
	@kubectl rollout status deployment -n $(NAMESPACE) -l tier=infrastructure --timeout=300s

scale: ## Scale specific service (SERVICE=service-name REPLICAS=number)
	@if [ -z "$(SERVICE)" ] || [ -z "$(REPLICAS)" ]; then \
		echo "$(RED)Usage: make scale SERVICE=service-name REPLICAS=number$(NC)"; \
		echo "$(YELLOW)Available services: user-service, product-service, cart-service, order-service, payment-service, notification-service, loyalty-service, shipping-service$(NC)"; \
		exit 1; \
	fi
	@kubectl scale deployment/$(SERVICE) -n $(NAMESPACE) --replicas=$(REPLICAS)
	@kubectl rollout status deployment/$(SERVICE) -n $(NAMESPACE)

# =============================================================================
# DEBUGGING AND TROUBLESHOOTING
# =============================================================================

debug: ## Debug specific service (SERVICE=service-name)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Usage: make debug SERVICE=service-name$(NC)"; \
		echo "$(YELLOW)Available services: user-service, product-service, cart-service, order-service, payment-service, notification-service, loyalty-service, shipping-service$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Debugging $(SERVICE)...$(NC)"
	@kubectl describe deployment/$(SERVICE) -n $(NAMESPACE)
	@echo ""
	@kubectl get pods -n $(NAMESPACE) -l app=$(SERVICE)
	@echo ""
	@kubectl logs -n $(NAMESPACE) -l app=$(SERVICE) --tail=100

debug-network: ## Debug network connectivity
	@echo "$(BLUE)Debugging network connectivity...$(NC)"
	@echo "$(YELLOW)Services:$(NC)"
	@kubectl get svc -n $(NAMESPACE)
	@echo ""
	@echo "$(YELLOW)Endpoints:$(NC)"
	@kubectl get endpoints -n $(NAMESPACE)
	@echo ""
	@echo "$(YELLOW)Ingress:$(NC)"
	@kubectl get ingress -n $(NAMESPACE)

debug-storage: ## Debug storage issues
	@echo "$(BLUE)Debugging storage...$(NC)"
	@echo "$(YELLOW)Persistent Volume Claims:$(NC)"
	@kubectl get pvc -n $(NAMESPACE)
	@echo ""
	@echo "$(YELLOW)Persistent Volumes:$(NC)"
	@kubectl get pv

diagnose: ## Run comprehensive diagnostics
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    Platform Diagnostics$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Checking cluster connectivity...$(NC)"
	@kubectl cluster-info || echo "$(RED)Cluster connection failed$(NC)"
	@echo ""
	@echo "$(YELLOW)2. Checking namespace...$(NC)"
	@kubectl get namespace $(NAMESPACE) || echo "$(RED)Namespace $(NAMESPACE) not found$(NC)"
	@echo ""
	@echo "$(YELLOW)3. Checking failed pods...$(NC)"
	@kubectl get pods -n $(NAMESPACE) --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || echo "$(GREEN)No failed pods$(NC)"
	@echo ""
	@echo "$(YELLOW)4. Checking recent events...$(NC)"
	@kubectl get events -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp --field-selector type=Warning | tail -10 || echo "$(GREEN)No recent warnings$(NC)"

# =============================================================================
# DEPENDENCY MANAGEMENT
# =============================================================================

dependencies: ## Update helm dependencies
	@echo "$(BLUE)Updating helm dependencies...$(NC)"
	helm dependency update

deps-check: ## Check if all dependencies are ready
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@echo "$(YELLOW)1. Checking data layer...$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=data || echo "$(RED)Data layer not found$(NC)"
	@echo ""
	@echo "$(YELLOW)2. Checking infrastructure layer...$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=infrastructure || echo "$(RED)Infrastructure layer not found$(NC)"
	@echo ""
	@echo "$(YELLOW)3. Checking microservices...$(NC)"
	@kubectl get pods -n $(NAMESPACE) -l tier=backend || echo "$(RED)Microservices not found$(NC)"

# =============================================================================
# BACKUP AND RECOVERY
# =============================================================================

backup: ## Create backup of platform configuration and data
	@echo "$(BLUE)Creating platform backup...$(NC)"
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@kubectl get all -n $(NAMESPACE) -o yaml > backups/$(shell date +%Y%m%d_%H%M%S)/all-resources.yaml
	@helm get values $(RELEASE_NAME) -n $(NAMESPACE) > backups/$(shell date +%Y%m%d_%H%M%S)/helm-values.yaml
	@echo "$(GREEN)Backup saved to backups/$(shell date +%Y%m%d_%H%M%S)/$(NC)"

backup-data: ## Backup application data
	@echo "$(BLUE)Creating data backup...$(NC)"
	@kubectl create job --from=cronjob/backup-job backup-$(shell date +%s) -n $(NAMESPACE) || echo "$(YELLOW)No backup cronjob found$(NC)"

# =============================================================================
# MONITORING AND ALERTING
# =============================================================================

metrics: ## Show key platform metrics
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    Platform Metrics$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Pod Resource Usage:$(NC)"
	@kubectl top pods -n $(NAMESPACE) --sort-by=memory || echo "$(RED)Metrics server not available$(NC)"
	@echo ""
	@echo "$(YELLOW)Node Resource Usage:$(NC)"
	@kubectl top nodes || echo "$(RED)Metrics server not available$(NC)"

monitor: ## Start continuous monitoring dashboard
	@echo "$(BLUE)Starting continuous monitoring (Press Ctrl+C to stop)...$(NC)"
	@while true; do \
		clear; \
		echo "$(CYAN)NexusCommerce Platform Monitor - $$(date)$(NC)"; \
		echo "========================================"; \
		kubectl get pods -n $(NAMESPACE) --no-headers | while read pod rest; do \
			status=$$(echo $$rest | awk '{print $$3}'); \
			if [ "$$status" = "Running" ]; then \
				echo "$(GREEN)✅ $$pod$(NC)"; \
			else \
				echo "$(RED)❌ $$pod ($$status)$(NC)"; \
			fi; \
		done; \
		echo ""; \
		echo "Memory Usage:"; \
		kubectl top pods -n $(NAMESPACE) 2>/dev/null | head -10 || echo "Metrics not available"; \
		sleep 10; \
	done

# =============================================================================
# SECURITY AND COMPLIANCE
# =============================================================================

security-scan: ## Run security scan on platform
	@echo "$(BLUE)Running security scan...$(NC)"
	@echo "$(YELLOW)Checking for security policies...$(NC)"
	@kubectl get networkpolicies -n $(NAMESPACE) || echo "$(YELLOW)No network policies found$(NC)"
	@echo ""
	@echo "$(YELLOW)Checking RBAC...$(NC)"
	@kubectl get rolebindings,clusterrolebindings -n $(NAMESPACE) || echo "$(YELLOW)No RBAC found$(NC)"
	@echo ""
	@echo "$(YELLOW)Checking pod security context...$(NC)"
	@kubectl get pods -n $(NAMESPACE) -o jsonpath='{.items[*].spec.securityContext}' | grep -o '"runAsNonRoot":[^,]*' || echo "$(YELLOW)Security context not set$(NC)"

# =============================================================================
# UTILITIES
# =============================================================================

get-passwords: ## Get default passwords for services
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    Service Credentials$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Grafana:$(NC)"
	@echo "  Username: admin"
	@echo "  Password: admin123 (dev) / check secret (prod)"
	@echo ""
	@echo "$(YELLOW)pgAdmin:$(NC)"
	@echo "  Username: admin@nexuscommerce.com"
	@echo "  Password: admin123 (dev) / check secret (prod)"
	@echo ""
	@echo "$(YELLOW)Database:$(NC)"
	@echo "  PostgreSQL: postgres/postgres123 (dev)"
	@echo "  MongoDB: admin/nexus123 (dev)"

context: ## Show current kubectl context
	@echo "$(BLUE)Current kubectl context:$(NC)"
	@kubectl config current-context
	@echo ""
	@echo "$(BLUE)Available contexts:$(NC)"
	@kubectl config get-contexts

version: ## Show platform version information
	@echo "$(CYAN)======================================================$(NC)"
	@echo "$(CYAN)    Version Information$(NC)"
	@echo "$(CYAN)======================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Platform Version:$(NC) $(CHART_VERSION)"
	@echo "$(YELLOW)Helm Version:$(NC)"
	@helm version --short
	@echo "$(YELLOW)Kubectl Version:$(NC)"
	@kubectl version --short --client
	@echo "$(YELLOW)Kubernetes Version:$(NC)"
	@kubectl version --short --output=yaml | grep gitVersion || echo "Cluster not accessible"