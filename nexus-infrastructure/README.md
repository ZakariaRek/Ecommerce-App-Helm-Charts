# NexusCommerce Infrastructure Helm Chart

A comprehensive Helm chart for deploying the complete NexusCommerce infrastructure stack including Service Discovery (Eureka), Configuration Management (Config Server), API Gateway, Distributed Tracing (Zipkin), and Ingress Controller.

## Overview

This chart deploys a full infrastructure platform for the NexusCommerce microservices ecosystem, providing:

- **Service Discovery** with Eureka Server for dynamic service registration and discovery
- **Configuration Management** with Config Server for centralized configuration
- **API Gateway** for request routing, rate limiting, and CORS handling
- **Distributed Tracing** with Zipkin for request tracking and performance monitoring
- **Ingress Controller** with Nginx for external traffic management
- **Health Monitoring** and actuator endpoints for all services

## Prerequisites

- Kubernetes 1.20+
- Helm 3.8+
- At least 4GB RAM and 2 CPU cores available in cluster
- Data layer services (MongoDB, PostgreSQL, Redis, Kafka) should be deployed first

## Quick Start

### 1. Deploy the data layer first
```bash
# Deploy the database/messaging infrastructure first
cd ../nexus-database
make dev
```

### 2. Install infrastructure for development
```bash
# Using make (recommended)
make dev

# Or using deployment script
./deploy.sh -e dev

# Or using helm directly
helm install nexus-infrastructure . -f values-dev.yaml --namespace infrastructure --create-namespace
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
| **prod** | High (3) | High | Production workloads |

### Values Files

- `values.yaml` - Default configuration
- `values-dev.yaml` - Development environment
- `values-staging.yaml` - Staging environment
- `values-prod.yaml` - Production environment

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
```

### Using Helm Directly

```bash
# Install
helm install nexus-infrastructure . -f values-dev.yaml --namespace infrastructure --create-namespace

# Upgrade
helm upgrade nexus-infrastructure . -f values-prod.yaml --namespace infrastructure

# Uninstall
helm uninstall nexus-infrastructure --namespace infrastructure
```

## Configuration Parameters

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `infrastructure` |
| `global.environment` | Environment name | `production` |
| `global.storageClass` | Storage class for PVs | `standard` |
| `global.nodeSelector` | Node selector for pods | `{node-role: infrastructure}` |

### Eureka Server Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `eureka.enabled` | Enable Eureka deployment | `true` |
| `eureka.name` | Eureka service name | `eureka-server` |
| `eureka.replicas` | Number of Eureka replicas | `2` |
| `eureka.image.repository` | Eureka image repository | `yahyazakaria123/ecommerce-app-discovery-service` |
| `eureka.image.tag` | Eureka image tag | `latest` |
| `eureka.service.port` | Eureka service port | `8761` |

### Config Server Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configServer.enabled` | Enable Config Server deployment | `true` |
| `configServer.name` | Config Server service name | `config-server` |
| `configServer.replicas` | Number of Config Server replicas | `1` |
| `configServer.config.gitUri` | Git repository URI | `https://github.com/Saoudyahya/...` |
| `configServer.service.port` | Config Server port | `8888` |

### API Gateway Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `apiGateway.enabled` | Enable API Gateway deployment | `true` |
| `apiGateway.name` | API Gateway service name | `api-gateway` |
| `apiGateway.replicas` | Number of API Gateway replicas | `2` |
| `apiGateway.service.port` | API Gateway port | `8099` |
| `apiGateway.config.cors.allowedOrigins` | CORS allowed origins | `http://localhost:3000,http://localhost:8080` |

### Zipkin Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `zipkin.enabled` | Enable Zipkin deployment | `true` |
| `zipkin.name` | Zipkin service name | `zipkin-server` |
| `zipkin.service.port` | Zipkin port | `9411` |
| `zipkin.storage.type` | Storage backend | `mem` |

### Ingress Controller Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress Controller | `true` |
| `ingress.name` | Ingress Controller name | `ingress-nginx` |
| `ingress.replicas` | Number of Ingress replicas | `2` |
| `ingress.service.type` | Ingress service type | `LoadBalancer` |

## Service Connections

After deployment, services can be accessed using these URLs:

### Internal Service URLs
```
# Service Discovery
http://eureka-server.infrastructure.svc.cluster.local:8761

# Configuration Management
http://config-server.infrastructure.svc.cluster.local:8888

# API Gateway
http://api-gateway.infrastructure.svc.cluster.local:8099

# Distributed Tracing
http://zipkin-server.infrastructure.svc.cluster.local:9411
```

### Health Check URLs
```
# Eureka Health
http://eureka-server.infrastructure.svc.cluster.local:8761/actuator/health

# Config Server Health
http://config-server.infrastructure.svc.cluster.local:8888/actuator/health

# API Gateway Health
http://api-gateway.infrastructure.svc.cluster.local:8099/actuator/health

# Zipkin Health
http://zipkin-server.infrastructure.svc.cluster.local:9411/health
```

## Monitoring & Observability

The chart includes comprehensive monitoring:

```yaml
monitoring:
  enabled: true
  prometheus:
    enabled: true
```

This enables:
- Health monitoring for all services
- Performance metrics collection
- Distributed tracing integration
- Actuator endpoints for Spring Boot services

## Local Development Access

For local development, use port forwarding:

```bash
# Set up port forwarding for all services
make port-forward

# Access services locally:
# Eureka: http://localhost:8761
# Config Server: http://localhost:8888
# API Gateway: http://localhost:8099
# Zipkin: http://localhost:9411
```

## Security

### Development
- Basic security configuration
- CORS enabled for development
- No network policies

### Production
- Enhanced security settings
- Network policies enabled
- RBAC configured
- Secure service communication

### Updating Secrets

```bash
# Update API Gateway JWT secret
kubectl create secret generic api-gateway-secrets \
  --from-literal=jwt-secret=your-new-jwt-secret \
  --namespace infrastructure \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Troubleshooting

### Common Issues

1. **Services not registering with Eureka**
   ```bash
   kubectl logs -n infrastructure eureka-server-0
   # Check for connectivity and configuration issues
   ```

2. **Config Server cannot access Git repository**
   ```bash
   kubectl logs -n infrastructure config-server-0
   # Check Git repository URL and network access
   ```

3. **API Gateway startup failures**
   ```bash
   kubectl logs -n infrastructure api-gateway-0
   # Check dependencies (Eureka, Config Server, Redis, Kafka)
   ```

### Useful Commands

```bash
# Check all infrastructure services status
make status

# View logs for all infrastructure pods
make logs

# Check service health
make health

# Restart all deployments
make restart

# Test connectivity from within cluster
kubectl run -n infrastructure debug --image=busybox -it --rm -- sh
# Then test: nc -zv eureka-server.infrastructure.svc.cluster.local 8761
```

### Deployment Order

For proper startup, ensure dependencies are available:

1. **Data Layer** (nexus-database chart)
    - Redis (for API Gateway caching/rate limiting)
    - Kafka (for API Gateway messaging)

2. **Infrastructure Services** (this chart)
    - Eureka Server (first)
    - Config Server (after Eureka)
    - API Gateway (after Eureka + Config Server + Data layer)
    - Zipkin (can start independently)
    - Ingress Controller (can start independently)

## Scaling

```bash
# Scale Eureka for high availability
helm upgrade nexus-infrastructure . \
  --set eureka.replicas=3 \
  --namespace infrastructure

# Scale API Gateway for load handling
helm upgrade nexus-infrastructure . \
  --set apiGateway.replicas=5 \
  --namespace infrastructure
```

## Uninstallation

### Complete Removal (⚠️ Data Loss)
```bash
# Using make
make clean

# Using script
./undeploy.sh -f

# Using helm
helm uninstall nexus-infrastructure -n infrastructure
```

### Keep Data (Preserve PVCs)
```bash
./undeploy.sh -k
```

## Development

### Chart Development

```bash
# Lint the chart
make lint

# Test template rendering
make test

# Debug template issues
helm template nexus-infrastructure . -f values-dev.yaml --debug
```

### Adding New Infrastructure Services

1. Add configuration to `values.yaml`
2. Create templates in `templates/` directory
3. Update `_helpers.tpl` with new labels
4. Test with `helm template`
5. Update documentation

## Integration with Microservices

This infrastructure chart is designed to work with:

- **User Service** - Registers with Eureka, gets config from Config Server
- **Product Service** - Uses API Gateway for routing, traced by Zipkin
- **Cart Service** - All infrastructure services integration
- **Order Service** - Full observability and configuration management
- **Payment Service** - Enhanced security through API Gateway
- **Shipping Service** - Service discovery and tracing
- **Loyalty Service** - Configuration management and monitoring
- **Notification Service** - Event processing through API Gateway

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Update documentation
5. Submit a pull request

## License

This chart is licensed under the MIT License. See LICENSE file for details.

## Support

- **Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **Discord**: [NexusCommerce Community](https://discord.gg/nexuscommerce)