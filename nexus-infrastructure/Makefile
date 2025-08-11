# nexus-infrastructure/Makefile
.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean

# Default values
ENVIRONMENT ?= dev
NAMESPACE ?= infrastructure
RELEASE_NAME ?= nexus-infrastructure

help: ## Show this help message
	@echo "NexusCommerce Infrastructure Helm Chart"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $1, $2}' $(MAKEFILE_LIST)

install: ## Install the chart (ENV=dev|staging|prod)
	@echo "Installing nexus-infrastructure for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME)

upgrade: ## Upgrade existing release (ENV=dev|staging|prod)
	@echo "Upgrading nexus-infrastructure for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade

uninstall: ## Uninstall the chart
	@echo "Uninstalling nexus-infrastructure..."
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
	@echo "Showing logs for infrastructure pods..."
	@kubectl logs -n $(NAMESPACE) -l tier=discovery --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=configuration --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=gateway --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=observability --tail=100 || true
	@kubectl logs -n $(NAMESPACE) -l tier=ingress --tail=100 || true

connect: ## Show connection information
	@echo "=== Connection Information ==="
	@echo "Service Endpoints:"
	@echo "  Eureka Server: http://eureka-server.$(NAMESPACE).svc.cluster.local:8761"
	@echo "  Config Server: http://config-server.$(NAMESPACE).svc.cluster.local:8888"
	@echo "  API Gateway: http://api-gateway.$(NAMESPACE).svc.cluster.local:8099"
	@echo "  Zipkin: http://zipkin-server.$(NAMESPACE).svc.cluster.local:9411"
	@echo ""
	@echo "Health Check URLs:"
	@echo "  Eureka: http://eureka-server.$(NAMESPACE).svc.cluster.local:8761/actuator/health"
	@echo "  Config Server: http://config-server.$(NAMESPACE).svc.cluster.local:8888/actuator/health"
	@echo "  API Gateway: http://api-gateway.$(NAMESPACE).svc.cluster.local:8099/actuator/health"
	@echo "  Zipkin: http://zipkin-server.$(NAMESPACE).svc.cluster.local:9411/health"

health: ## Check health of all services
	@echo "=== Health Check ==="
	@kubectl get pods -n $(NAMESPACE) -o wide
	@echo ""
	@echo "Service Status:"
	@kubectl get svc -n $(NAMESPACE)

port-forward: ## Port forward services for local access
	@echo "Setting up port forwarding..."
	@echo "Eureka: http://localhost:8761"
	@echo "Config Server: http://localhost:8888"
	@echo "API Gateway: http://localhost:8099"
	@echo "Zipkin: http://localhost:9411"
	@echo ""
	@echo "Press Ctrl+C to stop port forwarding"
	@kubectl port-forward -n $(NAMESPACE) svc/eureka-server 8761:8761 &
	@kubectl port-forward -n $(NAMESPACE) svc/config-server 8888:8888 &
	@kubectl port-forward -n $(NAMESPACE) svc/api-gateway 8099:8099 &
	@kubectl port-forward -n $(NAMESPACE) svc/zipkin-server 9411:9411 &
	@wait

restart: ## Restart all deployments
	@echo "Restarting all infrastructure deployments..."
	@kubectl rollout restart deployment -n $(NAMESPACE)
	@kubectl rollout status deployment -n $(NAMESPACE) --timeout=300s
