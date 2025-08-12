# NexusCommerce Microservices Helm Chart

A comprehensive Helm chart for deploying the complete NexusCommerce microservices ecosystem including User Management, Product Catalog, Shopping Cart, Order Processing, Payment Processing, Notifications, Loyalty Program, and Shipping Management.

## Overview

This chart deploys a complete microservices architecture for the NexusCommerce e-commerce platform, providing:

- **User Service** for user authentication, registration, and profile management
- **Product Service** for product catalog, search, and inventory management
- **Cart Service** for shopping cart session management and persistence
- **Order Service** for order processing, workflow, and history
- **Payment Service** for secure payment processing with multiple providers
- **Notification Service** for email, SMS, and real-time notifications
- **Loyalty Service** for customer loyalty programs and rewards
- **Shipping Service** for logistics, tracking, and delivery management

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Service  │    │ Product Service │    │  Cart Service   │
│    (Port 8081)  │    │   (Port 8082)   │    │   (Port 8082)   │
│                 │    │                 │    │                 │
│ • Authentication│    │ • Product CRUD  │    │ • Session Mgmt  │
│ • User Profiles │    │ • Search & Filt │    │ • Cart Persist  │
│ • OAuth2/JWT    │    │ • Categories    │    │ • Item Mgmt     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
      ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
      │  Order Service  │    │ Payment Service │    │ Notification    │
      │   (Port 8082)   │    │   (Port 8084)   │    │   Service       │
      │                 │    │                 │    │   (Port 8086)   │
      │ • Order Proc    │    │ • Stripe/PayPal │    │ • Email/SMS     │
      │ • Workflows     │    │ • Secure Trans  │    │ • Real-time     │
      │ • History       │    │ • Fraud Detect  │    │ • Templates     │
      └─────────────────┘    └─────────────────┘    └─────────────────┘
                │                       │                       │
                └───────────────────────┼───────────────────────┘
                                        │
            ┌─────────────────┐    ┌─────────────────┐
            │ Loyalty Service │    │ Shipping Service│
            │   (Port 8084)   │    │   (Port 8085)   │
            │                 │    │                 │
            │ • Points System │    │ • GPS Tracking  │
            │ • Tier Mgmt     │    │ • Real-time Loc │
            │ • Rewards       │    │ • Delivery Mgmt │
            └─────────────────┘    └─────────────────┘
```

## Prerequisites

- Kubernetes 1.20+
- Helm 3.8+
- At least 8GB RAM and 4 CPU cores available in cluster
- **Dependencies (must be deployed first):**
  - NexusCommerce Infrastructure (Eureka, Config Server, API Gateway, Zipkin)
  - NexusCommerce Database Layer (MongoDB, PostgreSQL, Redis, Kafka)

## Quick Start

### 1. Deploy dependencies first
```bash
# Deploy the database layer
cd ../nexus-database
make dev

# Deploy the infrastructure layer
cd ../nexus-infrastructure
make dev
```

### 2. Install microservices for development
```bash
# Using make (recommended)
make dev

# Or using deployment script
./deploy.sh -e dev

# Or using helm directly
helm install nexus-microservices . -f values-dev.yaml --namespace microservices --create-namespace
```

### 3. Install for production
```bash
# Using make (recommended)
make prod

# Or using the deployment script
./deploy.sh -e prod -u
```

## Configuration

### Environment-Specific Deployments

The chart supports three environments with different resource allocations:

| Environment | Replicas | Resources | Purpose |
|-------------|----------|-----------|---------|
| **dev** | Minimal (1) | Low | Development & testing |
| **staging** | Medium (2) | Medium | Pre-production testing |
| **prod** | High (2-3) | High | Production workloads |

### Values Files

- `values.yaml` - Default production configuration
- `values-dev.yaml` - Development environment (single replicas, NodePort access)
- `values-staging.yaml` - Staging environment
- `values-prod.yaml` - Production environment (high availability)

## Installation

### Using Make (Recommended)

```bash
# Development
make dev

# Staging
make staging

# Production
make prod

# Upgrade existing deployment
make upgrade ENVIRONMENT=prod

# Dry run
make dry-run ENVIRONMENT=staging
```

### Using Deployment Script

```bash
# Install development
./deploy.sh -e dev

# Install production with upgrade
./deploy.sh -e prod -u

# Dry run for staging
./deploy.sh -e staging -d

# Skip dependency checks
./deploy.sh -e dev -s
```

### Using Helm Directly

```bash
# Install
helm install nexus-microservices . -f values-dev.yaml --namespace microservices --create-namespace

# Upgrade
helm upgrade nexus-microservices . -f values-prod.yaml --namespace microservices

# Uninstall
helm uninstall nexus-microservices --namespace microservices
```

## Service Configuration

### User Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `userService.enabled` | Enable User Service | `true` |
| `userService.replicas` | Number of replicas | `2` |
| `userService.config.contextPath` | API context path | `/api/users` |
| `userService.config.database.name` | MongoDB database name | `User-service` |
| `userService.config.jwt.expirationMs` | JWT expiration time | `86400000` |

### Product Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `productService.enabled` | Enable Product Service | `true` |
| `productService.replicas` | Number of replicas | `2` |
| `productService.config.contextPath` | API context path | `/api/products` |
| `productService.config.database.name` | PostgreSQL database name | `productdb` |

### Cart Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cartService.enabled` | Enable Cart Service | `true` |
| `cartService.replicas` | Number of replicas | `2` |
| `cartService.config.contextPath` | API context path | `/api/carts` |
| `cartService.config.sessionTimeout` | Cart session timeout (seconds) | `1800` |
| `cartService.config.cacheTimeout` | Cache timeout (seconds) | `600` |

### Order Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `orderService.enabled` | Enable Order Service | `true` |
| `orderService.replicas` | Number of replicas | `2` |
| `orderService.config.database.name` | PostgreSQL database name | `orderdb` |

### Payment Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `paymentService.enabled` | Enable Payment Service | `true` |
| `paymentService.replicas` | Number of replicas | `2` |
| `paymentService.config.features.stripe` | Enable Stripe payments | `true` |
| `paymentService.config.features.paypal` | Enable PayPal payments | `false` |
| `paymentService.config.security.maxPaymentAmount` | Maximum payment amount | `10000.00` |

### Notification Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `notificationService.enabled` | Enable Notification Service | `true` |
| `notificationService.replicas` | Number of replicas | `2` |
| `notificationService.config.features.email` | Enable email notifications | `true` |
| `notificationService.config.features.sms` | Enable SMS notifications | `false` |
| `notificationService.config.features.websocket` | Enable WebSocket notifications | `false` |

### Loyalty Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `loyaltyService.enabled` | Enable Loyalty Service | `true` |
| `loyaltyService.replicas` | Number of replicas | `2` |
| `loyaltyService.config.contextPath` | API context path | `/api/loyalty` |
| `loyaltyService.config.tiers.goldThreshold` | Points for Gold tier | `2000` |
| `loyaltyService.config.points.orderRate` | Points per dollar spent | `1.0` |

### Shipping Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `shippingService.enabled` | Enable Shipping Service | `true` |
| `shippingService.replicas` | Number of replicas | `1` |
| `shippingService.config.features.gpsTracking` | Enable GPS tracking | `true` |
| `shippingService.config.features.realTimeLocation` | Enable real-time location | `true` |

## Service Endpoints

After deployment, services can be accessed using these URLs:

### Internal Service URLs
```
# User Management
http://user-service.microservices.svc.cluster.local:8081

# Product Catalog
http://product-service.microservices.svc.cluster.local:8082

# Shopping Cart
http://cart-service.microservices.svc.cluster.local:8082

# Order Processing
http://order-service.microservices.svc.cluster.local:8082

# Payment Processing
http://payment-service.microservices.svc.cluster.local:8084

# Notifications
http://notification-service.microservices.svc.cluster.local:8086

# Loyalty Program
http://loyalty-service.microservices.svc.cluster.local:8084

# Shipping Management
http://shipping-service.microservices.svc.cluster.local:8085
```

### API Endpoints
```
# User Service APIs
POST /api/users/auth/signin
POST /api/users/auth/signup
GET  /api/users/profile
PUT  /api/users/profile

# Product Service APIs
GET    /api/products
POST   /api/products
GET    /api/products/{id}
PUT    /api/products/{id}
DELETE /api/products/{id}
GET    /api/products/search?q={query}

# Cart Service APIs
GET    /api/carts
POST   /api/carts/items
PUT    /api/carts/items/{id}
DELETE /api/carts/items/{id}
DELETE /api/carts/clear

# Order Service APIs
GET  /api/orders
POST /api/orders
GET  /api/orders/{id}
PUT  /api/orders/{id}/status

# Payment Service APIs
POST /api/payments/process
POST /api/payments/refund
GET  /api/payments/{id}/status

# Notification Service APIs
GET  /api/notifications
POST /api/notifications/send
PUT  /api/notifications/{id}/read

# Loyalty Service APIs
GET  /api/loyalty/profile
POST /api/loyalty/points/earn
POST /api/loyalty/points/redeem
GET  /api/loyalty/history

# Shipping Service APIs
POST /api/shipping/create
GET  /api/shipping/{id}/track
PUT  /api/shipping/{id}/location
```

### Health Check URLs
```
# Individual Service Health
http://user-service.microservices.svc.cluster.local:8081/api/users/actuator/health
http://product-service.microservices.svc.cluster.local:8082/api/products/actuator/health
http://cart-service.microservices.svc.cluster.local:8082/api/carts/actuator/health
http://order-service.microservices.svc.cluster.local:8082/actuator/health
http://payment-service.microservices.svc.cluster.local:8084/health
http://notification-service.microservices.svc.cluster.local:8086/actuator/health
http://loyalty-service.microservices.svc.cluster.local:8084/api/loyalty/actuator/health
http://shipping-service.microservices.svc.cluster.local:8085/health
```

## Monitoring & Observability

The chart includes comprehensive monitoring:

```yaml
monitoring:
  enabled: true
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
```

This enables:
- Health monitoring for all microservices
- Performance metrics collection
- Distributed tracing integration with Zipkin
- Actuator endpoints for Spring Boot services
- Custom business metrics

## Local Development Access

For local development, use port forwarding:

```bash
# Set up port forwarding for all services
make port-forward

# Access services locally:
# User Service: http://localhost:8081
# Product Service: http://localhost:8082
# Cart Service: http://localhost:8083
# Order Service: http://localhost:8084
# Payment Service: http://localhost:8085
# Notification Service: http://localhost:8086
# Loyalty Service: http://localhost:8087
# Shipping Service: http://localhost:8088
```

Or for development environment with NodePort:

```bash
# Direct access via NodePort (dev environment)
# User Service: http://localhost:30081
# Product Service: http://localhost:30082
# Cart Service: http://localhost:30083
# Order Service: http://localhost:30084
# Payment Service: http://localhost:30085
# Notification Service: http://localhost:30086
# Loyalty Service: http://localhost:30087
# Shipping Service: http://localhost:30088
```

## Security

### Development
- Relaxed security for development
- CORS enabled for all origins
- No network policies
- Basic secrets management

### Production
- Enhanced security settings
- Network policies enabled
- RBAC configured
- Secure service communication
- Encrypted secrets
- Payment data encryption (PCI compliance ready)

### Updating Secrets

```bash
# Update User Service JWT secret
kubectl create secret generic user-service-secrets \
  --from-literal=jwt-secret=your-new-jwt-secret \
  --namespace microservices \
  --dry-run=client -o yaml | kubectl apply -f -

# Update Payment Service secrets
kubectl create secret generic payment-service-secrets \
  --from-literal=stripe-api-key=your-stripe-key \
  --from-literal=stripe-webhook-secret=your-webhook-secret \
  --namespace microservices \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Troubleshooting

### Common Issues

1. **Services not registering with Eureka**
   ```bash
   kubectl logs -n microservices user-service-0
   # Check connectivity to eureka-server.infrastructure
   ```

2. **Database connection failures**
   ```bash
   kubectl logs -n microservices product-service-0
   # Check if PostgreSQL/MongoDB services are running in data namespace
   ```

3. **Payment service startup failures**
   ```bash
   kubectl logs -n microservices payment-service-0
   # Check Stripe API keys and database connectivity
   ```

### Useful Commands

```bash
# Check all microservices status
make status

# View logs for all microservices
make logs

# View logs for specific service
make logs-user
make logs-product
make logs-payment

# Check service health
make health

# Restart all services
make restart

# Restart specific service
make restart-user

# Scale specific service
make scale SERVICE=user-service REPLICAS=3

# Debug specific service
make debug SERVICE=payment-service

# Test connectivity from within cluster
kubectl run -n microservices debug --image=busybox -it --rm -- sh
# Then test: nc -zv user-service.microservices.svc.cluster.local 8081
```

### Deployment Order

For proper startup, ensure dependencies are available:

1. **Data Layer** (nexus-database chart)
   - MongoDB (for User Service, Cart Service, Notification Service)
   - PostgreSQL (for Product Service, Order Service, Payment Service, Loyalty Service, Shipping Service)
   - Redis (for caching and session management)
   - Kafka (for inter-service messaging)

2. **Infrastructure Services** (nexus-infrastructure chart)
   - Eureka Server (service discovery)
   - Config Server (configuration management)
   - API Gateway (request routing)
   - Zipkin (distributed tracing)

3. **Microservices** (this chart)
   - User Service (first - provides authentication)
   - Product Service
   - Cart Service (depends on User Service)
   - Order Service (depends on User, Product, Cart Services)
   - Payment Service (depends on Order Service)
   - Notification Service (depends on Order, Payment Services)
   - Loyalty Service (depends on User, Order Services)
   - Shipping Service (depends on Order Service)

## Scaling

```bash
# Scale individual services
make scale SERVICE=user-service REPLICAS=5
make scale SERVICE=product-service REPLICAS=3

# Or using kubectl directly
kubectl scale deployment user-service --replicas=5 -n microservices

# Enable autoscaling (requires metrics server)
helm upgrade nexus-microservices . \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10 \
  --namespace microservices
```

## Data Persistence

### Database Configuration

Each service uses dedicated databases:

- **User Service**: MongoDB (user-mongodb)
- **Product Service**: PostgreSQL (product-postgres)
- **Cart Service**: MongoDB (cart-mongodb) + Redis (sessions)
- **Order Service**: PostgreSQL (order-postgres)
- **Payment Service**: PostgreSQL (payment-postgres)
- **Notification Service**: MongoDB (notification-mongodb)
- **Loyalty Service**: PostgreSQL (loyalty-postgres)
- **Shipping Service**: PostgreSQL (shipping-postgres)

### Backup Strategy

```bash
# Manual backup
make backup

# Automated backup (configured in production values)
# Daily backups with 30-day retention
```

## Service Mesh Integration

### Istio Support

```yaml
serviceMesh:
  enabled: true
  istio:
    enabled: true
    sidecarInjection: true
```

This enables:
- Automatic sidecar injection
- mTLS between services
- Traffic management
- Circuit breakers
- Observability

## API Documentation

Each service exposes Swagger/OpenAPI documentation:

```
# Swagger UI endpoints
http://user-service:8081/api/users/swagger-ui.html
http://product-service:8082/api/products/swagger-ui.html
http://cart-service:8082/api/carts/swagger-ui.html
http://loyalty-service:8084/api/loyalty/swagger-ui.html
```

## Testing

### Load Testing

```bash
# Install dependencies for testing
helm install nexus-microservices . -f values-dev.yaml

# Run load tests (requires k6 or similar)
kubectl run load-test --image=loadimpact/k6:latest --restart=Never -- run - <load-test.js
```

### Integration Testing

```bash
# Run integration tests
kubectl apply -f tests/integration-tests.yaml

# Check test results
kubectl logs -l app=integration-tests
```

## Uninstallation

### Complete Removal (⚠️ Data Loss)
```bash
# Using make
make clean

# Using script
./undeploy.sh -f

# Using helm
helm uninstall nexus-microservices -n microservices
```

### Keep Data (Preserve PVCs)
```bash
./undeploy.sh -k
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Update documentation
5. Submit a pull request

### Adding New Microservices

1. Add configuration to `values.yaml`
2. Create templates in `templates/service-name/` directory
3. Update `_helpers.tpl` with new labels
4. Add health checks and init containers
5. Test with `helm template`
6. Update documentation

## License

This chart is licensed under the MIT License. See LICENSE file for details.

## Support

- **Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **Discord**: [NexusCommerce Community](https://discord.gg/nexuscommerce)

## Roadmap

- [ ] Service mesh complete integration
- [ ] Advanced monitoring and alerting
- [ ] GraphQL federation gateway
- [ ] Event sourcing implementation
- [ ] Advanced security features (OAuth2, mTLS)
- [ ] Multi-region deployment support
- [ ] Chaos engineering integration