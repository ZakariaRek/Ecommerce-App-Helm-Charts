# 🚀 NexusCommerce Database Helm Chart

[![Helm Version](https://img.shields.io/badge/Helm-v3.8+-blue.svg)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-v1.20+-green.svg)](https://kubernetes.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Chart Version](https://img.shields.io/badge/Chart-v0.1.0-orange.svg)](Chart.yaml)

> A comprehensive, production-ready Helm chart for deploying the complete NexusCommerce database infrastructure including MongoDB, PostgreSQL, Redis, and Kafka messaging systems.

## 📋 Table of Contents

- [🏗️ Architecture Overview](#️-architecture-overview)
- [🎯 Features](#-features)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [⚙️ Configuration](#️-configuration)
- [🔧 Installation Methods](#-installation-methods)
- [🔗 Database Connections](#-database-connections)
- [📊 Monitoring & Observability](#-monitoring--observability)
- [🔒 Security](#-security)
- [💾 Backup & Recovery](#-backup--recovery)
- [🔍 Troubleshooting](#-troubleshooting)
- [🚀 Scaling](#-scaling)
- [🗑️ Uninstallation](#️-uninstallation)
- [🤝 Contributing](#-contributing)

## 🏗️ Architecture Overview

### Database Stack Architecture

```mermaid
graph TB
    subgraph "NexusCommerce Microservices"
        CS[Cart Service]
        US[User Service]
        PS[Product Service]
        PMS[Payment Service]
        OS[Order Service]
        LS[Loyalty Service]
        SS[Shipping Service]
    end
    
    subgraph "Database Layer"
        subgraph "MongoDB Cluster"
            CM[(Cart MongoDB)]
            UM[(User MongoDB)]
        end
        
        subgraph "PostgreSQL Cluster"
            PP[(Product DB)]
            PM[(Payment DB)]
            OP[(Order DB)]
            LP[(Loyalty DB)]
            SP[(Shipping DB)]
        end
        
        subgraph "Cache & Messaging"
            R[(Redis Cache)]
            K[Kafka Cluster]
            Z[Zookeeper]
        end
    end
    
    subgraph "Infrastructure"
        PV[Persistent Volumes]
        NS[Kubernetes Namespace]
        SC[Storage Classes]
    end
    
    CS --> CM
    US --> UM
    PS --> PP
    PMS --> PM
    OS --> OP
    LS --> LP
    SS --> SP
    
    CS --> R
    US --> R
    PS --> R
    
    CS --> K
    US --> K
    PS --> K
    PMS --> K
    OS --> K
    
    K --> Z
    
    CM --> PV
    UM --> PV
    PP --> PV
    PM --> PV
    OP --> PV
    R --> PV
    K --> PV
    
    style CM fill:#47A248
    style UM fill:#47A248
    style PP fill:#336791
    style PM fill:#336791
    style OP fill:#336791
    style LP fill:#336791
    style SP fill:#336791
    style R fill:#DC382D
    style K fill:#231F20
    style Z fill:#231F20
```

### Environment Deployment Strategy

```mermaid
graph LR
    DEV[🔧 Development<br/>Single Replicas<br/>Small Storage<br/>Basic Auth]
    STAGING[🚦 Staging<br/>Medium Replicas<br/>Medium Storage<br/>Enhanced Security]
    PROD[🏭 Production<br/>High Availability<br/>Large Storage<br/>Full Security]
    
    DEV -->|Promotion| STAGING
    STAGING -->|Promotion| PROD
    
    style DEV fill:#FFE4B5
    style STAGING fill:#FFD700
    style PROD fill:#90EE90
```

### Network Flow Diagram

```mermaid
graph TD
    subgraph "Kubernetes Cluster"
        subgraph "Data Namespace"
            subgraph "Services"
                CS[cart-mongodb-headless<br/>:27017]
                US[user-mongodb-headless<br/>:27017]
                PS[product-postgres-service<br/>:5432]
                RS[redis-service<br/>:6379]
                KS[kafka-service<br/>:9092]
            end
            
            subgraph "StatefulSets/Deployments"
                CM[cart-mongodb-0,1,2]
                UM[user-mongodb-0,1,2]
                PP[product-postgres-0,1]
                RD[redis-deployment]
                KD[kafka-deployment]
                ZD[zookeeper-deployment]
            end
        end
        
        subgraph "Application Namespace"
            APPS[Microservices]
        end
    end
    
    APPS --> CS
    APPS --> US
    APPS --> PS
    APPS --> RS
    APPS --> KS
    
    CS --> CM
    US --> UM
    PS --> PP
    RS --> RD
    KS --> KD
    
    KD --> ZD
    
    style APPS fill:#E1F5FE
    style CS fill:#C8E6C9
    style US fill:#C8E6C9
    style PS fill:#BBDEFB
    style RS fill:#FFCDD2
    style KS fill:#F3E5F5
```

## 🎯 Features

### 🗄️ **Multi-Database Support**
- **MongoDB**: Document storage for cart and user data
- **PostgreSQL**: Relational data for products, payments, orders, loyalty, and shipping
- **Redis**: High-performance caching and session management
- **Kafka**: Event streaming and messaging backbone

### 🌍 **Multi-Environment Ready**
- **Development**: Resource-optimized for local development
- **Staging**: Production-like environment for testing
- **Production**: High-availability, enterprise-grade deployment

### 🔄 **High Availability**
- StatefulSet deployments with configurable replicas
- Pod anti-affinity for optimal distribution
- Persistent volume management
- Health checks and auto-recovery

### 🛡️ **Security First**
- RBAC integration
- Network policies (production)
- Secret management
- Encrypted connections

### 📈 **Monitoring & Observability**
- Prometheus metrics integration
- Health check endpoints
- Performance monitoring
- Resource utilization tracking

## 📋 Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| **Kubernetes** | 1.20+ | Container orchestration |
| **Helm** | 3.8+ | Package management |
| **StorageClass** | Available | Persistent storage |
| **Resources** | 8GB RAM, 4 CPU | Minimum cluster capacity |

### Resource Requirements by Environment

```mermaid
graph LR
    subgraph "Development"
        D1[2 CPU Cores]
        D2[4GB RAM]
        D3[50GB Storage]
    end
    
    subgraph "Staging"
        S1[8 CPU Cores]
        S2[16GB RAM]
        S3[500GB Storage]
    end
    
    subgraph "Production"
        P1[16 CPU Cores]
        P2[32GB RAM]
        P3[2TB Storage]
    end
    
    style D1 fill:#FFE4B5
    style D2 fill:#FFE4B5
    style D3 fill:#FFE4B5
    style S1 fill:#FFD700
    style S2 fill:#FFD700
    style S3 fill:#FFD700
    style P1 fill:#90EE90
    style P2 fill:#90EE90
    style P3 fill:#90EE90
```

## 🚀 Quick Start

### 1. **Clone or Download**
```bash
# If using Git
git clone https://github.com/nexuscommerce/helm-charts.git
cd helm-charts/nexus-database

# Or download and extract
```

### 2. **Quick Development Deployment**
```bash
# Using make (recommended)
make dev

# Using helm directly
helm install nexus-database . -f values-dev.yaml \
  --namespace data --create-namespace
```

### 3. **Quick Production Deployment**
```bash
# Using make with enhanced deployment script
make prod

# Using deployment script directly
./deploy.sh -e prod -u
```

### 4. **Verify Installation**
```bash
# Check deployment status
make status

# View connection information
make connect

# Monitor logs
make logs
```

## ⚙️ Configuration

### Environment-Specific Deployments

| Environment | Replicas | Resources | Storage | Purpose |
|-------------|----------|-----------|---------|---------|
| **🔧 Development** | Minimal (1) | Low | Small | Local development & testing |
| **🚦 Staging** | Medium (2-3) | Medium | Medium | Pre-production validation |
| **🏭 Production** | High (3+) | High | Large | Live production workloads |

### Key Configuration Files

```mermaid
graph TB
    subgraph "Configuration Files"
        V1[values.yaml<br/>📋 Default Config]
        V2[values-dev.yaml<br/>🔧 Development]
        V3[values-staging.yaml<br/>🚦 Staging]
        V4[values-prod.yaml<br/>🏭 Production]
    end
    
    subgraph "Deployment Target"
        ENV[Environment Selection]
    end
    
    V1 --> ENV
    V2 --> ENV
    V3 --> ENV
    V4 --> ENV
    
    style V1 fill:#E3F2FD
    style V2 fill:#FFE4B5
    style V3 fill:#FFD700
    style V4 fill:#90EE90
```

### Core Parameters

#### Global Configuration
```yaml
global:
  namespace: data                    # Kubernetes namespace
  environment: production            # Environment identifier
  storageClass: standard            # Storage class for PVs
  nodeSelector:                     # Node placement
    node-role: data
```

#### MongoDB Configuration
```yaml
mongodb:
  enabled: true
  cart:
    enabled: true
    replicas: 2                     # Number of replicas
    database:
      name: cartdb                  # Database name
    auth:
      username: cartservice         # Service username
    storage:
      data:
        size: 10Gi                  # Data storage size
```

#### PostgreSQL Configuration
```yaml
postgresql:
  enabled: true
  product:
    enabled: true
    database:
      name: productdb
    auth:
      username: productservice
    storage:
      size: 10Gi
```

## 🔧 Installation Methods

### Method 1: Make Commands (Recommended)

```bash
# Development environment
make dev

# Staging environment
make staging

# Production environment
make prod

# Upgrade existing deployment
make upgrade ENVIRONMENT=prod

# Dry run to preview changes
make dry-run ENVIRONMENT=staging
```

### Method 2: Deployment Script

```bash
# Basic installation
./deploy.sh -e dev

# Production with upgrade
./deploy.sh -e prod -u

# Dry run for staging
./deploy.sh -e staging -d

# Force upgrade with debug
./deploy.sh -e prod -u --force --debug
```

### Method 3: Direct Helm Commands

```bash
# Install development
helm install nexus-database . \
  -f values-dev.yaml \
  --namespace data \
  --create-namespace

# Upgrade production
helm upgrade nexus-database . \
  -f values-prod.yaml \
  --namespace data \
  --timeout 15m

# Uninstall
helm uninstall nexus-database --namespace data
```

### Deployment Flow

```mermaid
graph TD
    START([Start Deployment])
    
    VALIDATE{Validate<br/>Environment}
    TOOLS{Check<br/>Tools}
    LINT{Lint<br/>Chart}
    
    NAMESPACE[Create<br/>Namespace]
    DEPLOY[Deploy<br/>Resources]
    WAIT[Wait for<br/>Ready State]
    
    VERIFY{Verify<br/>Health}
    SUCCESS([✅ Success])
    FAILURE([❌ Failure])
    
    START --> VALIDATE
    VALIDATE --> TOOLS
    TOOLS --> LINT
    LINT --> NAMESPACE
    NAMESPACE --> DEPLOY
    DEPLOY --> WAIT
    WAIT --> VERIFY
    
    VERIFY -->|All Healthy| SUCCESS
    VERIFY -->|Issues Found| FAILURE
    
    VALIDATE -->|Invalid| FAILURE
    TOOLS -->|Missing| FAILURE
    LINT -->|Failed| FAILURE
    
    style START fill:#E8F5E8
    style SUCCESS fill:#C8E6C9
    style FAILURE fill:#FFCDD2
    style VALIDATE fill:#FFF3E0
    style TOOLS fill:#F3E5F5
    style LINT fill:#E1F5FE
```

## 🔗 Database Connections

After successful deployment, services can connect using these URLs:

### 📊 Connection Overview

```mermaid
graph TB
    subgraph "Service Connections"
        CS[Cart Service]
        US[User Service]
        PS[Product Service]
        PMS[Payment Service]
        OS[Order Service]
        LS[Loyalty Service]
        SS[Shipping Service]
        ALL[All Services]
    end
    
    subgraph "Database URLs"
        CMURL["mongodb://cart-mongodb-headless.data.svc.cluster.local:27017/cartdb"]
        UMURL["mongodb://user-mongodb-headless.data.svc.cluster.local:27017/userdb"]
        PPURL["product-postgres-service.data.svc.cluster.local:5432/productdb"]
        PMURL["payment-postgres-service.data.svc.cluster.local:5432/paymentdb"]
        OPURL["order-postgres-service.data.svc.cluster.local:5432/orderdb"]
        LPURL["loyalty-postgres-service.data.svc.cluster.local:5432/loyalty-service"]
        SPURL["shipping-postgres-service.data.svc.cluster.local:5432/shippingdb"]
        RURL["redis-service.data.svc.cluster.local:6379"]
        KURL["kafka-service.data.svc.cluster.local:9092"]
    end
    
    CS --> CMURL
    US --> UMURL
    PS --> PPURL
    PMS --> PMURL
    OS --> OPURL
    LS --> LPURL
    SS --> SPURL
    ALL --> RURL
    ALL --> KURL
    
    style CMURL fill:#C8E6C9
    style UMURL fill:#C8E6C9
    style PPURL fill:#BBDEFB
    style PMURL fill:#BBDEFB
    style OPURL fill:#BBDEFB
    style LPURL fill:#BBDEFB
    style SPURL fill:#BBDEFB
    style RURL fill:#FFCDD2
    style KURL fill:#F3E5F5
```

### 🍃 MongoDB Connections
```bash
# Cart Service Database
mongodb://cart-mongodb-headless.data.svc.cluster.local:27017/cartdb

# User Service Database
mongodb://user-mongodb-headless.data.svc.cluster.local:27017/userdb
```

### 🐘 PostgreSQL Connections
```bash
# Product Service
product-postgres-service.data.svc.cluster.local:5432/productdb

# Payment Service
payment-postgres-service.data.svc.cluster.local:5432/paymentdb

# Order Service
order-postgres-service.data.svc.cluster.local:5432/orderdb

# Loyalty Service
loyalty-postgres-service.data.svc.cluster.local:5432/loyalty-service

# Shipping Service
shipping-postgres-service.data.svc.cluster.local:5432/shippingdb
```

### ⚡ Redis & Messaging
```bash
# Redis Cache
redis-service.data.svc.cluster.local:6379

# Kafka Messaging
kafka-service.data.svc.cluster.local:9092
```

### 🔐 Accessing Credentials
```bash
# List all secrets
kubectl get secrets -n data

# Get MongoDB password
kubectl get secret cart-mongodb-secret -n data -o jsonpath='{.data.password}' | base64 -d

# Get PostgreSQL password
kubectl get secret product-postgres-secret -n data -o jsonpath='{.data.password}' | base64 -d
```

## 📊 Monitoring & Observability

### Health Check Dashboard

```mermaid
graph TB
    subgraph "Health Monitoring"
        H1[🍃 MongoDB Health]
        H2[🐘 PostgreSQL Health]
        H3[⚡ Redis Health]
        H4[📨 Kafka Health]
    end
    
    subgraph "Metrics Collection"
        P[Prometheus]
        G[Grafana]
        A[Alertmanager]
    end
    
    subgraph "Observability Tools"
        L[Logs]
        M[Metrics]
        T[Traces]
    end
    
    H1 --> P
    H2 --> P
    H3 --> P
    H4 --> P
    
    P --> G
    P --> A
    
    P --> M
    G --> L
    A --> T
    
    style P fill:#FF6B35
    style G fill:#FF6B35
    style A fill:#FF6B35
```

### Enabling Monitoring
```yaml
monitoring:
  enabled: true
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
  grafana:
    enabled: true
    dashboards:
      enabled: true
```

### Health Check Commands
```bash
# Check all service health
make health

# Monitor real-time status
make watch

# View comprehensive logs
make logs

# Follow logs in real-time
make logs-follow
```

## 🔒 Security

### Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        subgraph "Network Security"
            NP[Network Policies]
            SG[Security Groups]
        end
        
        subgraph "Authentication"
            RBAC[RBAC Rules]
            SA[Service Accounts]
            SEC[Secrets Management]
        end
        
        subgraph "Encryption"
            TLS[TLS/SSL]
            ENC[Data Encryption]
        end
        
        subgraph "Access Control"
            PSP[Pod Security Policies]
            AC[Access Controls]
        end
    end
    
    NP --> RBAC
    RBAC --> TLS
    TLS --> PSP
    
    style NP fill:#FFCDD2
    style RBAC fill:#C8E6C9
    style TLS fill:#BBDEFB
    style PSP fill:#F3E5F5
```

### Environment Security Profiles

| Feature | Development | Staging | Production |
|---------|------------|---------|------------|
| **Network Policies** | ❌ Disabled | ✅ Basic | ✅ Strict |
| **RBAC** | 🔒 Basic | 🔒 Enhanced | 🔒 Full |
| **TLS/SSL** | ❌ Optional | ✅ Enabled | ✅ Required |
| **Secret Rotation** | ❌ Manual | 🔄 Scheduled | 🔄 Automated |
| **Audit Logging** | ❌ Disabled | 📝 Basic | 📝 Comprehensive |

### Updating Security Credentials

```bash
# Update MongoDB password
kubectl create secret generic cart-mongodb-secret \
  --from-literal=username=cartservice \
  --from-literal=password=your-secure-password \
  --namespace data \
  --dry-run=client -o yaml | kubectl apply -f -

# Update PostgreSQL password
kubectl create secret generic product-postgres-secret \
  --from-literal=username=productservice \
  --from-literal=password=your-secure-password \
  --namespace data \
  --dry-run=client -o yaml | kubectl apply -f -
```

## 💾 Backup & Recovery

### Backup Strategy

```mermaid
graph LR
    subgraph "Backup Sources"
        M[MongoDB Data]
        P[PostgreSQL Data]
        R[Redis Snapshots]
        C[Configuration]
    end
    
    subgraph "Backup Process"
        S[Scheduled Jobs]
        I[Immediate Backup]
        V[Validation]
    end
    
    subgraph "Storage"
        L[Local Storage]
        CLO[Cloud Storage]
        OFF[Offsite Backup]
    end
    
    M --> S
    P --> S
    R --> I
    C --> V
    
    S --> L
    I --> CLO
    V --> OFF
    
    style M fill:#C8E6C9
    style P fill:#BBDEFB
    style R fill:#FFCDD2
    style S fill:#FFF3E0
    style L fill:#F3E5F5
```

### Enabling Automated Backups

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"        # Daily at 2 AM
  retention: 30                # Keep for 30 days
  storage:
    type: "persistent-volume"
    size: "100Gi"
  destinations:
    - local
    - s3
```

### Manual Backup Operations

```bash
# Trigger immediate backup
make backup-now

# MongoDB manual backup
kubectl exec -n data cart-mongodb-0 -- \
  mongodump --out /tmp/backup --authenticationDatabase admin

# PostgreSQL manual backup
kubectl exec -n data product-postgres-0 -- \
  pg_dump productdb > /tmp/product-backup.sql

# Redis snapshot
kubectl exec -n data redis-service-0 -- redis-cli BGSAVE
```

### Recovery Procedures

```bash
# Restore from backup (example)
./restore.sh --backup-date 2024-01-15 --component mongodb

# Point-in-time recovery
./restore.sh --timestamp "2024-01-15 14:30:00" --database productdb
```

## 🔍 Troubleshooting

### Common Issues Resolution

```mermaid
graph TD
    ISSUE{🚨 Issue Type}
    
    POD[Pod Issues]
    STORAGE[Storage Issues]
    NETWORK[Network Issues]
    PERF[Performance Issues]
    
    POD_STEPS[1. Check pod status<br/>2. View pod logs<br/>3. Describe pod events<br/>4. Check resource limits]
    STORAGE_STEPS[1. Check PVC status<br/>2. Verify StorageClass<br/>3. Check disk space<br/>4. Review volume mounts]
    NETWORK_STEPS[1. Test connectivity<br/>2. Check services<br/>3. Verify DNS resolution<br/>4. Review network policies]
    PERF_STEPS[1. Monitor resources<br/>2. Check database performance<br/>3. Review configurations<br/>4. Scale if needed]
    
    ISSUE --> POD
    ISSUE --> STORAGE
    ISSUE --> NETWORK
    ISSUE --> PERF
    
    POD --> POD_STEPS
    STORAGE --> STORAGE_STEPS
    NETWORK --> NETWORK_STEPS
    PERF --> PERF_STEPS
    
    style ISSUE fill:#FFCDD2
    style POD fill:#FFE4B5
    style STORAGE fill:#E1F5FE
    style NETWORK fill:#F3E5F5
    style PERF fill:#C8E6C9
```

### Diagnostic Commands

```bash
# Comprehensive status check
make status

# Debug deployment issues
make debug

# Describe failed pods
make describe

# Check cluster resources
kubectl top nodes
kubectl top pods -n data

# View recent events
kubectl get events -n data --sort-by='.lastTimestamp' --field-selector type=Warning
```

### Issue-Specific Solutions

#### 🚨 **Pods Stuck in Pending**
```bash
# Check resource constraints
kubectl describe nodes
kubectl describe pod <pod-name> -n data

# Common solutions:
# - Insufficient cluster resources
# - StorageClass issues
# - Node selector constraints
```

#### 🚨 **MongoDB Connection Failures**
```bash
# Check MongoDB status
kubectl logs -n data cart-mongodb-0

# Verify authentication
kubectl exec -n data cart-mongodb-0 -- mongosh --eval "db.adminCommand('ping')"

# Check service connectivity
kubectl exec -n data debug-pod -- nc -zv cart-mongodb-headless 27017
```

#### 🚨 **PostgreSQL Startup Issues**
```bash
# Check PostgreSQL logs
kubectl logs -n data product-postgres-0

# Verify database readiness
kubectl exec -n data product-postgres-0 -- pg_isready

# Check permissions
kubectl exec -n data product-postgres-0 -- ls -la /var/lib/postgresql/data
```

## 🚀 Scaling

### Scaling Strategy

```mermaid
graph TB
    subgraph "Scaling Triggers"
        CPU[High CPU Usage]
        MEM[Memory Pressure]
        CON[Connection Load]
        STO[Storage Growth]
    end
    
    subgraph "Scaling Actions"
        VREP[Vertical: Resources]
        HREP[Horizontal: Replicas]
        STOR[Storage: Expansion]
        SHARD[Sharding: Distribution]
    end
    
    subgraph "Monitoring"
        PROM[Prometheus Alerts]
        GRAF[Grafana Dashboards]
        AUTO[Auto-scaling]
    end
    
    CPU --> VREP
    MEM --> VREP
    CON --> HREP
    STO --> STOR
    
    VREP --> PROM
    HREP --> GRAF
    STOR --> AUTO
    
    style CPU fill:#FFCDD2
    style CON fill:#FFE4B5
    style VREP fill:#C8E6C9
    style HREP fill:#BBDEFB
```

### Horizontal Scaling

```bash
# Scale MongoDB replicas
helm upgrade nexus-database . \
  --set mongodb.cart.replicas=3 \
  --namespace data

# Scale PostgreSQL (requires read replicas)
kubectl scale statefulset product-postgres --replicas=2 -n data

# Scale Redis for clustering
helm upgrade nexus-database . \
  --set redis.replicas=3 \
  --namespace data
```

### Vertical Scaling

```bash
# Increase resources
helm upgrade nexus-database . \
  --set mongodb.cart.resources.limits.memory=2Gi \
  --set mongodb.cart.resources.limits.cpu=1000m \
  --namespace data
```

### Storage Expansion

```bash
# Expand PVC (if StorageClass supports it)
kubectl patch pvc mongodb-data-cart-mongodb-0 \
  -n data \
  -p '{"spec":{"resources":{"requests":{"storage":"50Gi"}}}}'
```

## 🗑️ Uninstallation

### Uninstall Options

```mermaid
graph TD
    START([Start Uninstall])
    
    CHOICE{Preserve Data?}
    
    SOFT[Soft Uninstall<br/>Keep PVCs]
    HARD[Complete Uninstall<br/>Delete Everything]
    
    BACKUP{Backup First?}
    
    CREATE_BACKUP[Create Backup]
    SKIP_BACKUP[Skip Backup]
    
    REMOVE_HELM[Remove Helm Release]
    REMOVE_PVC[Remove PVCs]
    REMOVE_NS[Remove Namespace]
    
    COMPLETE([✅ Complete])
    
    START --> CHOICE
    
    CHOICE -->|Yes| SOFT
    CHOICE -->|No| HARD
    
    HARD --> BACKUP
    BACKUP -->|Yes| CREATE_BACKUP
    BACKUP -->|No| SKIP_BACKUP
    
    SOFT --> REMOVE_HELM
    CREATE_BACKUP --> REMOVE_HELM
    SKIP_BACKUP --> REMOVE_HELM
    
    REMOVE_HELM --> REMOVE_PVC
    REMOVE_PVC --> REMOVE_NS
    REMOVE_NS --> COMPLETE
    
    SOFT --> COMPLETE
    
    style START fill:#E8F5E8
    style SOFT fill:#C8E6C9
    style HARD fill:#FFCDD2
    style COMPLETE fill:#E8F5E8
```

### Safe Uninstallation (Preserve Data)

```bash
# Using make
make clean

# Using undeploy script (keeps PVCs)
./undeploy.sh -k

# Using helm (manual PVC management)
helm uninstall nexus-database -n data
# PVCs remain for later use
```

### Complete Removal (⚠️ Data Loss)

```bash
# Using undeploy script with force
./undeploy.sh -f

# Manual complete removal
helm uninstall nexus-database -n data
kubectl delete pvc --all -n data
kubectl delete namespace data
```

### Backup Before Uninstall

```bash
# Create backup before removal
./undeploy.sh --backup-first -k

# Verify backup completion before proceeding
kubectl get jobs -n data
```

## 🤝 Contributing

### Development Workflow

```mermaid
graph LR
    FORK[🍴 Fork Repository]
    CLONE[📥 Clone Fork]
    BRANCH[🌿 Create Branch]
    CODE[💻 Make Changes]
    TEST[🧪 Test Changes]
    PR[📤 Pull Request]
    REVIEW[👀 Code Review]
    MERGE[🔀 Merge]
    
    FORK --> CLONE
    CLONE --> BRANCH
    BRANCH --> CODE
    CODE --> TEST
    TEST --> PR
    PR --> REVIEW
    REVIEW --> MERGE
    
    style FORK fill:#E8F5E8
    style TEST fill:#FFF3E0
    style REVIEW fill:#F3E5F5
    style MERGE fill:#C8E6C9
```

### Contributing Steps

1. **🍴 Fork the repository**
2. **🌿 Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **💻 Make your changes**
4. **🧪 Test thoroughly**
   ```bash
   make lint
   make test
   make template-all
   ```
5. **📝 Update documentation**
6. **📤 Submit a pull request**

### Chart Development

```bash
# Lint the chart
make lint

# Test template rendering
make test

# Debug template issues
helm template nexus-database . -f values-dev.yaml --debug

# Package for distribution
make package
```

### Adding New Databases

1. **📝 Add configuration to `values.yaml`**
2. **🗂️ Create templates in `templates/` directory**
3. **🏷️ Update `_helpers.tpl` with new labels**
4. **🧪 Test with `helm template`**
5. **📚 Update documentation**

---

## 🆘 Support & Resources

### 📞 **Getting Help**
- **📚 Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **🐛 Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **💬 Community**: [Discord Server](https://discord.gg/nexuscommerce)
- **📧 Email**: [team@nexuscommerce.com](mailto:team@nexuscommerce.com)

### 🏷️ **Version Information**
- **Chart Version**: 0.1.0
- **App Version**: 1.0.0
- **Kubernetes**: 1.20+
- **Helm**: 3.8+

### 📄 **License**
This chart is licensed under the **MIT License**. See [LICENSE](LICENSE) file for details.

---

<div align="center">

**🚀 Built with ❤️ by the NexusCommerce Team**

[![GitHub Stars](https://img.shields.io/github/stars/nexuscommerce/helm-charts?style=social)](https://github.com/nexuscommerce/helm-charts)
[![Discord](https://img.shields.io/discord/123456789?label=Discord&logo=discord&logoColor=white)](https://discord.gg/nexuscommerce)
[![Twitter Follow](https://img.shields.io/twitter/follow/nexuscommerce?style=social)](https://twitter.com/nexuscommerce)

</div>