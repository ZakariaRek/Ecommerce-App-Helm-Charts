# nexus-microservices/Makefile
.PHONY: help install upgrade uninstall dry-run lint test dev staging prod clean

# Default values
ENVIRONMENT ?= dev
NAMESPACE ?= microservices
RELEASE_NAME ?= nexus-microservices

help: ## Show this help message
	@echo "NexusCommerce Microservices Helm Chart"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $1, $2}' $(MAKEFILE_LIST)

install: ## Install the chart (ENV=dev|staging|prod)
	@echo "Installing nexus-microservices for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME)

upgrade: ## Upgrade existing release (ENV=dev|staging|prod)
	@echo "Upgrading nexus-microservices for $(ENVIRONMENT) environment..."
	./deploy.sh -e $(ENVIRONMENT) -n $(NAMESPACE) -r $(RELEASE_NAME) --upgrade

uninstall: ## Uninstall the chart
	@echo "Uninstalling nexus-microservices..."
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

logs: ## Show logs for all microservices
	@echo "Showing logs for microservices..."
	@kubectl logs -n $(NAMESPACE) -l app=user-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=product-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=cart-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=order-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=payment-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=notification-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=loyalty-service --tail=50 || true
	@kubectl logs -n $(NAMESPACE) -l app=shipping-service --tail=50 || true

logs-user: ## Show user service logs
	@kubectl logs -n $(NAMESPACE) -l app=user-service -f

logs-product: ## Show product service logs
	@kubectl logs -n $(NAMESPACE) -l app=product-service -f

logs-cart: ## Show cart service logs
	@kubectl logs -n $(NAMESPACE) -l app=cart-service -f

logs-order: ## Show order service logs
	@kubectl logs -n $(NAMESPACE) -l app=order-service -f

logs-payment: ## Show payment service logs
	@kubectl logs -n $(NAMESPACE) -l app=payment-service -f

logs-notification: ## Show notification service logs
	@kubectl logs -n $(NAMESPACE) -l app=notification-service -f

logs-loyalty: ## Show loyalty service logs
	@kubectl logs -n $(NAMESPACE) -l app=loyalty-service -f

logs-shipping: ## Show shipping service logs
	@kubectl logs -n $(NAMESPACE) -l app=shipping-service -f

connect: ## Show connection information
	@echo "=== Microservices Connection Information ==="
	@echo "Internal Service Endpoints:"
	@echo "  User Service: http://user-service.$(NAMESPACE).svc.cluster.local:8081"
	@echo "  Product Service: http://product-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Cart Service: http://cart-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Order Service: http://order-service.$(NAMESPACE).svc.cluster.local:8082"
	@echo "  Payment Service: http://payment-service.$(NAMESPACE).svc.cluster.local:8084"
	@echo "  Notification Service: http://notification-service.$(NAMESPACE).svc.cluster.local:8086"
	@echo "  Loyalty Service: http://loyalty-service.$(NAMESPACE).svc.cluster.local:8084"
	@echo "  Shipping Service: http://shipping-service.$(NAMESPACE).svc.cluster.local:8085"
	@echo ""
	@echo "Health Check URLs:"
	@echo "  User: http://user-service.$(NAMESPACE).svc.cluster.local:8081/api/users/actuator/health"
	@echo "  Product: http://product-service.$(NAMESPACE).svc.cluster.local:8082/api/products/actuator/health"
	@echo "  Cart: http://cart-service.$(NAMESPACE).svc.cluster.local:8082/api/carts/actuator/health"
	@echo "  Order: http://order-service.$(NAMESPACE).svc.cluster.local:8082/actuator/health"
	@echo "  Payment: http://payment-service.$(NAMESPACE).svc.cluster.local:8084/health"
	@echo "  Notification: http://notification-service.$(NAMESPACE).svc.cluster.local:8086/actuator/health"
	@echo "  Loyalty: http://loyalty-service.$(NAMESPACE).svc.cluster.local:8084/api/loyalty/actuator/health"
	@echo "  Shipping: http://shipping-service.$(NAMESPACE).svc.cluster.local:8085/health"

health: ## Check health of all microservices
	@echo "=== Microservices Health Check ==="
	@kubectl get pods -n $(NAMESPACE) -o wide
	@echo ""
	@echo "Service Status:"
	@kubectl get svc -n $(NAMESPACE)
	@echo ""
	@echo "Checking individual service health..."
	@kubectl get pods -n $(NAMESPACE) --no-headers | while read pod rest; do \
		echo "Pod: $$pod"; \
		kubectl get pod $$pod -n $(NAMESPACE) -o jsonpath='{.status.phase}' && echo; \
	done

port-forward: ## Port forward all services for local access
	@echo "Setting up port forwarding for all microservices..."
	@echo "User Service: http://localhost:8081"
	@echo "Product Service: http://localhost:8082" 
	@echo "Cart Service: http://localhost:8083"
	@echo "Order Service: http://localhost:8084"
	@echo "Payment Service: http://localhost:8085"
	@echo "Notification Service: http://localhost:8086"
	@echo "Loyalty Service: http://localhost:8087"
	@echo "Shipping Service: http://localhost:8088"
	@echo ""
	@echo "Press Ctrl+C to stop port forwarding"
	@kubectl port-forward -n $(NAMESPACE) svc/user-service 8081:8081 &
	@kubectl port-forward -n $(NAMESPACE) svc/product-service 8082:8082 &
	@kubectl port-forward -n $(NAMESPACE) svc/cart-service 8083:8082 &
	@kubectl port-forward -n $(NAMESPACE) svc/order-service 8084:8082 &
	@kubectl port-forward -n $(NAMESPACE) svc/payment-service 8085:8084 &
	@kubectl port-forward -n $(NAMESPACE) svc/notification-service 8086:8086 &
	@kubectl port-forward -n $(NAMESPACE) svc/loyalty-service 8087:8084 &
	@kubectl port-forward -n $(NAMESPACE) svc/shipping-service 8088:8085 &
	@wait

restart: ## Restart all microservices
	@echo "Restarting all microservice deployments..."
	@kubectl rollout restart deployment -n $(NAMESPACE)
	@kubectl rollout status deployment -n $(NAMESPACE) --timeout=600s

restart-user: ## Restart user service
	@kubectl rollout restart deployment/user-service -n $(NAMESPACE)
	@kubectl rollout status deployment/user-service -n $(NAMESPACE)

restart-product: ## Restart product service
	@kubectl rollout restart deployment/product-service -n $(NAMESPACE)
	@kubectl rollout status deployment/product-service -n $(NAMESPACE)

restart-cart: ## Restart cart service
	@kubectl rollout restart deployment/cart-service -n $(NAMESPACE)
	@kubectl rollout status deployment/cart-service -n $(NAMESPACE)

restart-order: ## Restart order service
	@kubectl rollout restart deployment/order-service -n $(NAMESPACE)
	@kubectl rollout status deployment/order-service -n $(NAMESPACE)

restart-payment: ## Restart payment service
	@kubectl rollout restart deployment/payment-service -n $(NAMESPACE)
	@kubectl rollout status deployment/payment-service -n $(NAMESPACE)

restart-notification: ## Restart notification service
	@kubectl rollout restart deployment/notification-service -n $(NAMESPACE)
	@kubectl rollout status deployment/notification-service -n $(NAMESPACE)

restart-loyalty: ## Restart loyalty service
	@kubectl rollout restart deployment/loyalty-service -n $(NAMESPACE)
	@kubectl rollout status deployment/loyalty-service -n $(NAMESPACE)

restart-shipping: ## Restart shipping service
	@kubectl rollout restart deployment/shipping-service -n $(NAMESPACE)
	@kubectl rollout status deployment/shipping-service -n $(NAMESPACE)

scale: ## Scale services (SERVICE=service-name REPLICAS=number)
	@if [ -z "$(SERVICE)" ] || [ -z "$(REPLICAS)" ]; then \
		echo "Usage: make scale SERVICE=service-name REPLICAS=number"; \
		echo "Available services: user-service, product-service, cart-service, order-service, payment-service, notification-service, loyalty-service, shipping-service"; \
		exit 1; \
	fi
	@kubectl scale deployment/$(SERVICE) -n $(NAMESPACE) --replicas=$(REPLICAS)
	@kubectl rollout status deployment/$(SERVICE) -n $(NAMESPACE)

debug: ## Debug a specific service (SERVICE=service-name)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make debug SERVICE=service-name"; \
		echo "Available services: user-service, product-service, cart-service, order-service, payment-service, notification-service, loyalty-service, shipping-service"; \
		exit 1; \
	fi
	@echo "Debugging $(SERVICE)..."
	@kubectl describe deployment/$(SERVICE) -n $(NAMESPACE)
	@echo ""
	@kubectl get pods -n $(NAMESPACE) -l app=$(SERVICE)
	@echo ""
	@kubectl logs -n $(NAMESPACE) -l app=$(SERVICE) --tail=100

dependencies: ## Check and install dependencies
	@echo "Checking dependencies..."
	@echo "1. Checking infrastructure services..."
	@kubectl get svc -n infrastructure || echo "Infrastructure services not found. Run: cd ../nexus-infrastructure && make dev"
	@echo ""
	@echo "2. Checking data services..."
	@kubectl get svc -n data || echo "Data services not found. Run: cd ../nexus-database && make dev"

migration: ## Run database migrations (if applicable)
	@echo "Running database migrations..."
	@kubectl create job --from=cronjob/database-migration migration-$(shell date +%s) -n $(NAMESPACE) || echo "No migration job found"

backup: ## Backup microservices data
	@echo "Creating backup of microservices data..."
	@kubectl create job --from=cronjob/backup-job backup-$(shell date +%s) -n $(NAMESPACE) || echo "No backup job found"

monitoring: ## Enable monitoring for microservices
	@echo "Enabling monitoring..."
	@kubectl apply -f monitoring/ -n $(NAMESPACE) || echo "No monitoring configuration found"