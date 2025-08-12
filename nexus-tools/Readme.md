# NexusCommerce Tools Helm Chart

A comprehensive Helm chart for deploying monitoring, observability, and management tools for the NexusCommerce microservices platform.

## Overview

This chart deploys a complete tooling stack including:

- **Kafka UI** - Web interface for managing Apache Kafka clusters
- **Prometheus** - Metrics collection and monitoring system
- **Grafana** - Data visualization and monitoring dashboards
- **Swagger UI** - Interactive API documentation
- **Adminer** - Database administration tool
- **pgAdmin** - PostgreSQL administration tool
- **Redis Commander** - Redis database management interface
- **Optional tools**: Jaeger (tracing), Kiali (service mesh), ELK Stack (logging)

## Prerequisites

- Kubernetes 1.20+
- Helm 3.8+
- At least 2GB RAM and 1 CPU core available in cluster
- NexusCommerce infrastructure should be deployed first
- Data layer services (Kafka, Redis, PostgreSQL) should be available

## Quick Start

### 1. Deploy infrastructure and data layers first
```bash
# Deploy infrastructure
cd ../nexus-infrastructure
make dev

# Deploy data layer (if not already deployed)
cd ../nexus-database
make dev
```

### 2. Install tools for development
```bash
# Using make (recommended)
make dev

# Or using deployment script
./deploy.sh -e dev

# Or using helm directly
helm install nexus-tools . -f values-dev.yaml --namespace tools --create-namespace
```

### 3. Install for production
```bash
# Using make (recommended)
make prod

# Or using deployment script
./deploy.sh -e prod -u
```

## Tools Included

### Core Tools (Always Enabled)

| Tool | Purpose | Default Port | Access Path |
|------|---------|--------------|-------------|
| **Kafka UI** | Kafka cluster management | 8080 | /kafka-ui |
| **Prometheus** | Metrics collection | 9090 | /prometheus |
| **Grafana** | Monitoring dashboards | 3000 | /grafana |
| **Swagger UI** | API documentation | 8080 | /swagger |

### Database Tools

| Tool | Purpose | Default Port | Access Path |
|------|---------|--------------|-------------|
| **Adminer** | Universal database admin | 8080 | /adminer |
| **pgAdmin** | PostgreSQL administration | 80 | /pgadmin |
| **Redis Commander** | Redis management | 8081 | /redis |

### Optional Tools

| Tool | Purpose | Default Port | Status |
|------|---------|--------------|--------|
| **Jaeger** | Distributed tracing | 16686 | Disabled (use Zipkin) |
| **Kiali** | Service mesh observability | 20001 | Disabled |
| **ElasticSearch** | Log storage | 9200 | Disabled in dev |
| **Kibana** | Log visualization | 5601 | Disabled in dev |

## Configuration

### Environment-Specific Deployments

| Environment | Purpose | Resource Allocation | Storage |
|-------------|---------|-------------------|---------|
| **dev** | Development & testing | Low (shared resources) | Minimal |
| **staging** | Pre-production testing | Medium | Standard |
| **prod** | Production workloads | High (dedicated resources) | Persistent |

### Values Files

- `values.yaml` - Default configuration
- `values-dev.yaml` - Development environment (resource-optimized)
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
```

### Using Helm Directly

```bash
# Install
helm install nexus-tools . -f values-dev.yaml --namespace tools --create-namespace

# Upgrade
helm upgrade nexus-tools . -f values-prod.yaml --namespace tools

# Uninstall
helm uninstall nexus-tools --namespace tools
```

## Accessing Tools

### Local Development Access

```bash
# Set up port forwarding for all tools
make port-forward

# Access tools at:
# Kafka UI: http://localhost:8080
# Prometheus: http://localhost:9090  
# Grafana: http://localhost:3000
# Swagger UI: http://localhost:8081
# Adminer: http://localhost:8082
# pgAdmin: http://localhost:8083
# Redis Commander: http://localhost:8084
```

### Ingress Access (if enabled)

```bash
# Add to /etc/hosts (development)
echo "127.0.0.1 tools.nexus-commerce.local" >> /etc/hosts

# Access via ingress
# http://tools.nexus-commerce.local/kafka-ui
# http://tools.nexus-commerce.local/grafana
# http://tools.nexus-commerce.local/prometheus
```

### Default Credentials

| Tool | Username | Password | Notes |
|------|----------|----------|-------|
| **Grafana** | admin | admin123 | Change in production |
| **pgAdmin** | admin@nexuscommerce.com | admin123 | Change in production |
| **Adminer** | - | - | Database-specific |
| **Others** | - | - | No authentication |

## Configuration Parameters

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `tools` |
| `global.environment` | Environment name | `production` |
| `global.storageClass` | Storage class for PVs | `standard` |
| `global.nodeSelector` | Node selector for pods | `{node-role: infrastructure}` |

### Kafka UI Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kafkaUI.enabled` | Enable Kafka UI | `true` |
| `kafkaUI.replicas` | Number of replicas | `1` |
| `kafkaUI.config.kafka.bootstrapServers` | Kafka servers | `kafka-service.data.svc.cluster.local:9092` |

### Prometheus Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prometheus.enabled` | Enable Prometheus | `true` |
| `prometheus.replicas` | Number of replicas | `1` |
| `prometheus.storage.size` | Storage size | `10Gi` |
| `prometheus.config.retention` | Data retention | `30d` |

### Grafana Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `grafana.enabled` | Enable Grafana | `true` |
| `grafana.replicas` | Number of replicas | `1` |
| `grafana.storage.size` | Storage size | `5Gi` |
| `grafana.config.adminPassword` | Admin password | `admin123` |

## Monitoring & Dashboards

### Grafana Dashboards

Pre-configured dashboards include:

1. **Infrastructure Overview**
   - Cluster resource usage
   - Node performance metrics
   - Network traffic

2. **Microservices Dashboard**
   - Service response times
   - Error rates
   - Request throughput

3. **Database Monitoring**
   - PostgreSQL performance
   - Redis metrics
   - Connection pools

4. **Kafka Monitoring**
   - Topic metrics
   - Consumer lag
   - Broker performance

### Prometheus Targets

Automatically configured to scrape:

- Kubernetes cluster metrics
- Application metrics (via actuator)
- Infrastructure components
- Custom business metrics

## Troubleshooting

### Common Issues

1. **Tools not accessible**
   ```bash
   # Check pod status
   kubectl get pods -n tools
   
   # Check service endpoints
   kubectl get svc -n tools
   
   # Check ingress configuration
   kubectl get ingress -n tools
   ```

2. **Grafana login issues**
   ```bash
   # Get admin password
   make grafana-password
   
   # Reset to default if needed
   kubectl delete secret grafana-secret -n tools
   helm upgrade nexus-tools . -f values-dev.yaml
   ```

3. **Prometheus not collecting metrics**
   ```bash
   # Check targets
   make prometheus-targets
   
   # Verify service discovery
   kubectl logs -n tools deployment/prometheus
   ```

4. **Kafka UI connection issues**
   ```bash
   # Verify Kafka connectivity
   kubectl exec -n tools deployment/kafka-ui -- nc -zv kafka-service.data.svc.cluster.local 9092
   
   # Check configuration
   kubectl get configmap kafka-ui-config -n tools -o yaml
   ```

### Useful Commands

```bash
# Check all tools status
make status

# View logs for all tools
make logs

# Monitor tools health continuously
make monitor

# Scale deployments
make scale REPLICAS=2

# Restart all deployments
make restart

# Create configuration backup
make backup
```

## Performance Tuning

### Resource Optimization

```bash
# For development (resource-constrained)
helm upgrade nexus-tools . -f values-dev.yaml \
  --set prometheus.storage.size=1Gi \
  --set grafana.storage.size=500Mi

# For production (performance-optimized)
helm upgrade nexus-tools . -f values-prod.yaml \
  --set prometheus.replicas=2 \
  --set grafana.replicas=2
```

### Storage Optimization

```bash
# Use faster storage class for production
helm upgrade nexus-tools . \
  --set global.storageClass=fast-ssd

# Optimize retention periods
helm upgrade nexus-tools . \
  --set prometheus.config.retention=7d
```

## Integration with NexusCommerce

### Service Discovery

Tools automatically discover and monitor:

- **Infrastructure Services**: Eureka, Config Server, API Gateway
- **Microservices**: User, Product, Cart, Order, Payment services
- **Data Layer**: PostgreSQL, Redis, Kafka, MongoDB

### Metrics Collection

Prometheus is configured to collect:

- Application metrics (via Spring Boot Actuator)
- JVM metrics (heap, GC, threads)
- HTTP request metrics (latency, throughput, errors)
- Custom business metrics

### Log Aggregation (Optional)

When ELK stack is enabled:

- Centralized log collection from all services
- Log parsing and indexing
- Real-time log analysis in Kibana
- Log-based alerting

## Security

### Development
- Basic authentication where applicable
- No network policies
- Simple passwords

### Production
- Strong passwords required
- Network policies enabled
- RBAC configured
- SSL/TLS encryption

### Securing Tools

```bash
# Update Grafana password
kubectl create secret generic grafana-secret \
  --from-literal=password=your-strong-password \
  --namespace tools \
  --dry-run=client -o yaml | kubectl apply -f -

# Update pgAdmin password
kubectl create secret generic pgadmin-secret \
  --from-literal=password=your-strong-password \
  --namespace tools \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Scaling

### Horizontal Scaling

```bash
# Scale Prometheus for high availability
helm upgrade nexus-tools . \
  --set prometheus.replicas=3

# Scale Grafana for load distribution
helm upgrade nexus-tools . \
  --set grafana.replicas=2
```

### Vertical Scaling

```bash
# Increase Prometheus resources
helm upgrade nexus-tools . \
  --set prometheus.resources.limits.memory=4Gi \
  --set prometheus.resources.limits.cpu=2000m
```

## Backup and Recovery

### Configuration Backup

```bash
# Create full backup
make backup

# Manual backup
kubectl get all -n tools -o yaml > tools-backup-$(date +%Y%m%d).yaml
```

### Data Backup

```bash
# Prometheus data backup (if persistent storage enabled)
kubectl exec -n tools prometheus-0 -- tar czf /tmp/prometheus-backup.tar.gz /prometheus

# Grafana dashboard backup
kubectl exec -n tools grafana-0 -- sqlite3 /var/lib/grafana/grafana.db .dump > grafana-backup.sql
```

## Uninstallation

### Complete Removal

```bash
# Using make
make clean

# Using script with data preservation
./undeploy.sh -k

# Using helm (keeps PVCs)
helm uninstall nexus-tools -n tools
```

### Selective Removal

```bash
# Disable specific tools
helm upgrade nexus-tools . \
  --set elasticsearch.enabled=false \
  --set kibana.enabled=false
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add/modify tool configurations
4. Test thoroughly with all environments
5. Update documentation
6. Submit a pull request

## License

This chart is licensed under the MIT License. See LICENSE file for details.

## Support

- **Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **Discord**: [NexusCommerce Community](https://discord.gg/nexuscommerce)

---

**Note**: This tools chart is designed to work seamlessly with the NexusCommerce infrastructure and microservices charts. Ensure proper deployment order: database → infrastructure → tools → microservices.