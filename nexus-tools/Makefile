# nexus-tools/Makefile
.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean

# Default values
ENVIRONMENT ?= dev
NAMESPACE ?= tools
RELEASE_NAME ?= nexus-tools

help: ## Show this help message
	@echo "NexusCommerce Tools Helm Chart"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $1, $2}' $(MAKEFILE_LIST)

install: ## Install the chart (ENV=dev|staging|prod)
	@echo "Installing nexus-tools for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME)

upgrade: ## Upgrade existing release (ENV=dev|staging|prod)
	@echo "Upgrading nexus-tools for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade

uninstall: ## Uninstall the chart
	@echo "Uninstalling nexus-tools..."
	./undeploy.sh -n $(NAMESPACE) -r $(RELEASE_NAME)

dry-run: ## Perform a dry run (ENV=dev|staging|prod)
	@echo "Dry run for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --dry-run

lint: ## Lint the helm chart
	@echo "Linting helm chart..."
	helm lint .

test: ## Test the helm chart
	@echo "Testing helm chart..."
	helm template $(RELEASE_NAME) . -f values-dev.yaml --debug

dev: ## Deploy to development
	$(MAKE) install ENVIRONMENT=dev

staging: ## Deploy to staging
	$(MAKE) install ENVIRONMENT=staging

prod: ## Deploy to production
	$(MAKE) install ENVIRONMENT=prod

clean: ## Clean up development environment
	$(MAKE) uninstall ENVIRONMENT=dev

status: ## Show deployment status
	@echo "Checking deployment status..."
	@helm list -n $(NAMESPACE)
	@echo ""
	@kubectl get all -n $(NAMESPACE)

logs: ## Show logs for all pods
	@echo "Showing logs for tools pods..."
	@kubectl logs -n $(NAMESPACE) -l tier=messaging --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=monitoring --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=documentation --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=database --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=cache --tail=100 || true

connect: ## Show connection information
	@echo "=== Connection Information ==="
	@echo "Tool Endpoints:"
	@echo "  Kafka UI: http://kafka-ui.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  Prometheus: http://prometheus.$(NAMESPACE).svc.cluster.local:9090"
	@echo "  Grafana: http://grafana.$(NAMESPACE).svc.cluster.local:3000"
	@echo "  Swagger UI: http://swagger-ui.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  Adminer: http://adminer.$(NAMESPACE).svc.cluster.local:8080"
	@echo "  pgAdmin: http://pgadmin.$(NAMESPACE).svc.cluster.local:80"
	@echo "  Redis Commander: http://redis-commander.$(NAMESPACE).svc.cluster.local:8081"
	@echo ""
	@echo "Health Check URLs:"
	@echo "  Kafka UI: http://kafka-ui.$(NAMESPACE).svc.cluster.local:8080/actuator/health"
	@echo "  Prometheus: http://prometheus.$(NAMESPACE).svc.cluster.local:9090/-/healthy"
	@echo "  Grafana: http://grafana.$(NAMESPACE).svc.cluster.local:3000/api/health"

health: ## Check health of all services
	@echo "=== Health Check ==="
	@kubectl get pods -n $(NAMESPACE) -o wide
	@echo ""
	@echo "Service Status:"
	@kubectl get svc -n $(NAMESPACE)

port-forward: ## Port forward services for local access
	@echo "Setting up port forwarding..."
	@echo "Kafka UI: http://localhost:8080"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000"
	@echo "Swagger UI: http://localhost:8081"
	@echo "Adminer: http://localhost:8082"
	@echo "pgAdmin: http://localhost:8083"
	@echo "Redis Commander: http://localhost:8084"
	@echo ""
	@echo "Press Ctrl+C to stop port forwarding"
	@kubectl port-forward -n $(NAMESPACE) svc/kafka-ui 8080:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/prometheus 9090:9090 &
	@kubectl port-forward -n $(NAMESPACE) svc/grafana 3000:3000 &
	@kubectl port-forward -n $(NAMESPACE) svc/swagger-ui 8081:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/adminer 8082:8080 &
	@kubectl port-forward -n $(NAMESPACE) svc/pgadmin 8083:80 &
	@kubectl port-forward -n $(NAMESPACE) svc/redis-commander 8084:8081 &
	@wait

restart: ## Restart all deployments
	@echo "Restarting all tools deployments..."
	@kubectl rollout restart deployment -n $(NAMESPACE)
	@kubectl rollout status deployment -n $(NAMESPACE) --timeout=300s

monitor: ## Monitor tools health continuously
	@echo "=== Continuous Health Monitoring ==="
	@echo "Press Ctrl+C to stop monitoring"
	@while true; do \
		clear; \
		echo "$(shell date): Tools Health Status"; \
		echo "========================================"; \
		kubectl get pods -n $(NAMESPACE) --no-headers | while read pod rest; do \
			status=$$(echo $$rest | awk '{print $$3}'); \
			if [ "$$status" = "Running" ]; then \
				echo "✅ $$pod"; \
			else \
				echo "❌ $$pod ($$status)"; \
			fi; \
		done; \
		echo ""; \
		echo "Memory Usage:"; \
		kubectl top pods -n $(NAMESPACE) 2>/dev/null || echo "Metrics not available"; \
		sleep 10; \
	done

scale: ## Scale deployments (REPLICAS=2)
	@echo "Scaling deployments to $(REPLICAS) replicas..."
	@kubectl scale deployment --replicas=$(REPLICAS) -n $(NAMESPACE) --all

backup: ## Create backup of tool configurations
	@echo "Creating backup of tool configurations..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@kubectl get all -n $(NAMESPACE) -o yaml > backups/$(shell date +%Y%m%d_%H%M%S)/tools-backup.yaml
	@echo "Backup saved to backups/$(shell date +%Y%m%d_%H%M%S)/"

grafana-password: ## Get Grafana admin password
	@echo "Grafana admin credentials:"
	@echo "Username: admin"
	@echo "Password: $$(kubectl get secret -n $(NAMESPACE) grafana-secret -o jsonpath='{.data.password}' | base64 -d || echo 'admin123')"

prometheus-targets: ## Show Prometheus targets
	@echo "=== Prometheus Targets ==="
	@kubectl port-forward -n $(NAMESPACE) svc/prometheus 9090:9090 &
	@sleep 3
	@echo "Open http://localhost:9090/targets in your browser"
	@echo "Press any key to stop port forwarding..."
	@read
	@pkill -f "kubectl port-forward.*prometheus"

tools-dashboard: ## Open tools dashboard in browser
	@echo "Opening tools dashboard..."
	@if command -v open >/dev/null 2>&1; then \
		kubectl port-forward -n $(NAMESPACE) svc/grafana 3000:3000 & \
		sleep 3; \
		open http://localhost:3000; \
		echo "Grafana opened. Use 'make grafana-password' to get credentials"; \
	else \
		echo "Please manually open http://localhost:3000 after running 'make port-forward'"; \
	fi