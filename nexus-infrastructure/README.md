# NexusCommerce Infrastructure Helm Chart

<div align="center">

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=Helm&labelColor=0F1689)
![Spring](https://img.shields.io/badge/spring-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)

**🚀 A comprehensive Helm chart for deploying the complete NexusCommerce infrastructure stack**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Helm Version](https://img.shields.io/badge/Helm-v3.8+-blue.svg)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-v1.20+-green.svg)](https://kubernetes.io/)

</div>

## 🏗️ System Architecture

```mermaid
graph TB
    subgraph "External Traffic"
        U[Users] --> LB[Load Balancer]
        EXT[External Services] --> LB
    end
    
    subgraph "Kubernetes Cluster"
        subgraph "Infrastructure Namespace"
            LB --> ING[Ingress Controller<br/>nginx]
            ING --> GW[API Gateway<br/>:8099]
            
            subgraph "Service Discovery"
                EUR[Eureka Server<br/>:8761]
            end
            
            subgraph "Configuration"
                CS[Config Server<br/>:8888]
            end
            
            subgraph "Observability"
                ZIP[Zipkin Server<br/>:9411]
            end
            
            GW --> EUR
            GW --> CS
            CS --> EUR
            
            GW -.->|traces| ZIP
            EUR -.->|traces| ZIP
            CS -.->|traces| ZIP
        end
        
        subgraph "Data Namespace"
            RED[Redis<br/>:6379]
            KAF[Kafka<br/>:9092]
            MON[MongoDB<br/>:27017]
            PG[PostgreSQL<br/>:5432]
        end
        
        subgraph "Microservices Namespace"
            US[User Service]
            PS[Product Service]
            CS_MS[Cart Service]
            OS[Order Service]
            PMS[Payment Service]
            SS[Shipping Service]
        end
        
        GW --> RED
        GW --> KAF
        
        US --> EUR
        PS --> EUR
        CS_MS --> EUR
        OS --> EUR
        PMS --> EUR
        SS --> EUR
        
        US --> MON
        PS --> PG
        OS --> PG
        
        US -.->|traces| ZIP
        PS -.->|traces| ZIP
        CS_MS -.->|traces| ZIP
    end
    
    style EUR fill:#e1f5fe
    style CS fill:#f3e5f5
    style GW fill:#e8f5e8
    style ZIP fill:#fff3e0
    style ING fill:#fce4ec
```

## 📋 Overview

This chart deploys a full infrastructure platform for the NexusCommerce microservices ecosystem, providing:

### 🔍 **Service Discovery**
- **Eureka Server** for dynamic service registration and discovery
- Automatic health monitoring and load balancing

### ⚙️ **Configuration Management**
- **Config Server** for centralized configuration
- Git-based configuration with hot reloading

### 🌐 **API Gateway**
- Request routing, rate limiting, and CORS handling
- JWT authentication and request transformation

### 📊 **Distributed Tracing**
- **Zipkin** for request tracking and performance monitoring
- End-to-end observability across services

### 🚪 **Ingress Controller**
- **Nginx** for external traffic management
- SSL termination and load balancing

### 💊 **Health Monitoring**
- Actuator endpoints for all services
- Comprehensive health checks and metrics

## 🚀 Quick Start

### Prerequisites

```mermaid
graph LR
    A[Kubernetes 1.20+] --> B[Helm 3.8+]
    B --> C[4GB RAM Available]
    C --> D[2 CPU Cores]
    D --> E[Data Layer Services]
    
    style A fill:#e3f2fd
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#fce4ec
    style E fill:#f3e5f5
```

### 🏃‍♂️ Quick Deployment

```bash
# 1. Deploy data layer first
cd ../nexus-database
make dev

# 2. Deploy infrastructure
make dev

# 3. Verify deployment
make status
```

## 🎯 Deployment Flow

```mermaid
flowchart TD
    START([Start Deployment]) --> CHECK{Prerequisites Check}
    CHECK -->|✅ Pass| NS[Create Namespace]
    CHECK -->|❌ Fail| ERROR[❌ Exit with Error]
    
    NS --> DATA{Data Layer Ready?}
    DATA -->|❌ No| DEPLOY_DATA[Deploy Data Layer]
    DATA -->|✅ Yes| EUR_DEPLOY[Deploy Eureka Server]
    DEPLOY_DATA --> EUR_DEPLOY
    
    EUR_DEPLOY --> EUR_WAIT[Wait for Eureka Ready]
    EUR_WAIT --> CS_DEPLOY[Deploy Config Server]
    CS_DEPLOY --> CS_WAIT[Wait for Config Server Ready]
    
    CS_WAIT --> PARALLEL{Deploy in Parallel}
    PARALLEL --> ZIP_DEPLOY[Deploy Zipkin]
    PARALLEL --> ING_DEPLOY[Deploy Ingress Controller]
    PARALLEL --> GW_DEPLOY[Deploy API Gateway]
    
    ZIP_DEPLOY --> HEALTH[Health Checks]
    ING_DEPLOY --> HEALTH
    GW_DEPLOY --> GW_WAIT[Wait for Dependencies]
    GW_WAIT --> HEALTH
    
    HEALTH --> VERIFY{All Services Healthy?}
    VERIFY -->|✅ Yes| SUCCESS[🎉 Deployment Complete]
    VERIFY -->|❌ No| TROUBLESHOOT[🔧 Troubleshoot]
    TROUBLESHOOT --> HEALTH
    
    style START fill:#e8f5e8
    style SUCCESS fill:#c8e6c9
    style ERROR fill:#ffcdd2
    style TROUBLESHOOT fill:#fff3e0
```

## 🌍 Environment Configurations

| Environment | 🔧 Replicas | 💾 Resources | 🎯 Purpose |
|-------------|-------------|--------------|------------|
| **🧪 Development** | Minimal (1) | Low | Development & testing |
| **🚦 Staging** | Medium (2) | Medium | Pre-production testing |
| **🏭 Production** | High (3) | High | Production workloads |

### 📝 Values Files Structure

```mermaid
graph TD
    BASE[values.yaml<br/>Base Configuration] --> DEV[values-dev.yaml<br/>Development Overrides]
    BASE --> STAGING[values-staging.yaml<br/>Staging Overrides]
    BASE --> PROD[values-prod.yaml<br/>Production Overrides]
    
    DEV --> D1[Single Replica]
    DEV --> D2[Low Resources]
    DEV --> D3[NodePort Services]
    
    STAGING --> S1[2 Replicas]
    STAGING --> S2[Medium Resources]
    STAGING --> S3[Basic Monitoring]
    
    PROD --> P1[3+ Replicas]
    PROD --> P2[High Resources]
    PROD --> P3[Full Security]
    PROD --> P4[Advanced Monitoring]
    
    style BASE fill:#e3f2fd
    style DEV fill:#e8f5e8
    style STAGING fill:#fff3e0
    style PROD fill:#ffebee
```

## 📦 Installation

### 🎯 Using Make (Recommended)

```bash
# 🧪 Development
make dev

# 🚦 Staging  
make staging

# 🏭 Production
make prod

# 🔄 Upgrade existing deployment
make upgrade ENVIRONMENT=prod

# 🧪 Dry run
make dry-run ENVIRONMENT=staging
```

### 🔧 Using Deployment Script

```bash
# Install development
./deploy.sh -e dev

# Install production with upgrade
./deploy.sh -e prod -u

# Dry run for staging
./deploy.sh -e staging -d
```

### ⚙️ Using Helm Directly

```bash
# Install
helm install nexus-infrastructure . \
  -f values-dev.yaml \
  --namespace infrastructure \
  --create-namespace

# Upgrade
helm upgrade nexus-infrastructure . \
  -f values-prod.yaml \
  --namespace infrastructure
```

## 🔧 Configuration Parameters

### 🌐 Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `infrastructure` |
| `global.environment` | Environment name | `production` |
| `global.storageClass` | Storage class for PVs | `standard` |
| `global.nodeSelector` | Node selector for pods | `{node-role: infrastructure}` |

### 🔍 Service Discovery (Eureka)

```mermaid
graph TB
    MS1[Microservice 1] -->|register| EUR[Eureka Server]
    MS2[Microservice 2] -->|register| EUR
    MS3[Microservice 3] -->|register| EUR
    
    MS1 -->|discover| EUR
    MS2 -->|discover| EUR
    MS3 -->|discover| EUR
    
    EUR -->|health check| MS1
    EUR -->|health check| MS2
    EUR -->|health check| MS3
    
    style EUR fill:#e1f5fe
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `eureka.enabled` | Enable Eureka deployment | `true` |
| `eureka.replicas` | Number of Eureka replicas | `2` |
| `eureka.image.repository` | Eureka image repository | `yahyazakaria123/ecommerce-app-discovery-service` |
| `eureka.service.port` | Eureka service port | `8761` |

### ⚙️ Configuration Management (Config Server)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `configServer.enabled` | Enable Config Server | `true` |
| `configServer.replicas` | Number of replicas | `1` |
| `configServer.config.gitUri` | Git repository URI | `https://github.com/Saoudyahya/...` |
| `configServer.service.port` | Config Server port | `8888` |

### 🌐 API Gateway

| Parameter | Description | Default |
|-----------|-------------|---------|
| `apiGateway.enabled` | Enable API Gateway | `true` |
| `apiGateway.replicas` | Number of replicas | `2` |
| `apiGateway.service.port` | API Gateway port | `8099` |
| `apiGateway.config.cors.allowedOrigins` | CORS allowed origins | `http://localhost:3000,http://localhost:8080` |

### 📊 Distributed Tracing (Zipkin)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `zipkin.enabled` | Enable Zipkin | `true` |
| `zipkin.service.port` | Zipkin port | `9411` |
| `zipkin.storage.type` | Storage backend | `mem` |

## 🔗 Service Communication

```mermaid
sequenceDiagram
    participant C as Client
    participant I as Ingress
    participant G as API Gateway
    participant E as Eureka
    participant CS as Config Server
    participant MS as Microservice
    participant Z as Zipkin
    
    C->>I: HTTP Request
    I->>G: Route Request
    G->>E: Service Discovery
    E-->>G: Service Locations
    G->>CS: Get Configuration
    CS-->>G: Configuration Data
    G->>MS: Forward Request
    MS-->>G: Response
    G-->>I: Response
    I-->>C: HTTP Response
    
    Note over G,Z: Tracing Data
    G->>Z: Send Trace
    MS->>Z: Send Trace
```

### 🔗 Internal Service URLs

```yaml
# Service Discovery
eureka: http://eureka-server.infrastructure.svc.cluster.local:8761

# Configuration Management  
config: http://config-server.infrastructure.svc.cluster.local:8888

# API Gateway
gateway: http://api-gateway.infrastructure.svc.cluster.local:8099

# Distributed Tracing
zipkin: http://zipkin-server.infrastructure.svc.cluster.local:9411
```

### 💊 Health Check URLs

```yaml
# Health Endpoints
eureka-health: http://eureka-server.infrastructure.svc.cluster.local:8761/actuator/health
config-health: http://config-server.infrastructure.svc.cluster.local:8888/actuator/health
gateway-health: http://api-gateway.infrastructure.svc.cluster.local:8099/actuator/health
zipkin-health: http://zipkin-server.infrastructure.svc.cluster.local:9411/health
```

## 📊 Monitoring & Observability

```mermaid
graph TB
    subgraph "Application Layer"
        APP1[User Service]
        APP2[Product Service]
        APP3[Order Service]
    end
    
    subgraph "Infrastructure Layer"
        EUR[Eureka Server]
        GW[API Gateway]
        CS[Config Server]
    end
    
    subgraph "Observability Stack"
        ZIP[Zipkin<br/>Distributed Tracing]
        PROM[Prometheus<br/>Metrics Collection]
        HEALTH[Health Checks<br/>Actuator Endpoints]
    end
    
    APP1 --> ZIP
    APP2 --> ZIP
    APP3 --> ZIP
    EUR --> ZIP
    GW --> ZIP
    CS --> ZIP
    
    APP1 --> PROM
    APP2 --> PROM
    APP3 --> PROM
    EUR --> PROM
    GW --> PROM
    CS --> PROM
    
    APP1 --> HEALTH
    APP2 --> HEALTH
    APP3 --> HEALTH
    EUR --> HEALTH
    GW --> HEALTH
    CS --> HEALTH
    
    style ZIP fill:#fff3e0
    style PROM fill:#e8f5e8
    style HEALTH fill:#e1f5fe
```

## 🛠️ Local Development Access

```bash
# Set up port forwarding for all services
make port-forward

# Access services locally:
# 🔍 Eureka: http://localhost:8761
# ⚙️ Config Server: http://localhost:8888
# 🌐 API Gateway: http://localhost:8099
# 📊 Zipkin: http://localhost:9411
```

## 🔒 Security Configuration

```mermaid
graph TD
    subgraph "Development"
        D1[Basic Security]
        D2[CORS Enabled]
        D3[No Network Policies]
    end
    
    subgraph "Production"
        P1[Enhanced Security]
        P2[Network Policies]
        P3[RBAC Configured]
        P4[Secure Communication]
    end
    
    DEV[Development Environment] --> D1
    DEV --> D2
    DEV --> D3
    
    PROD[Production Environment] --> P1
    PROD --> P2
    PROD --> P3
    PROD --> P4
    
    style DEV fill:#e8f5e8
    style PROD fill:#ffebee
    style P1 fill:#c8e6c9
    style P2 fill:#c8e6c9
    style P3 fill:#c8e6c9
    style P4 fill:#c8e6c9
```

## 🔧 Troubleshooting

```mermaid
flowchart TD
    ISSUE[🚨 Issue Detected] --> TYPE{Issue Type?}
    
    TYPE -->|Service Discovery| EUR_DEBUG[🔍 Eureka Debug]
    TYPE -->|Configuration| CS_DEBUG[⚙️ Config Server Debug]
    TYPE -->|Gateway| GW_DEBUG[🌐 Gateway Debug]
    TYPE -->|Connectivity| CONN_DEBUG[🔗 Connection Debug]
    
    EUR_DEBUG --> EUR_LOGS[Check Eureka Logs]
    EUR_LOGS --> EUR_HEALTH[Check Health Endpoint]
    EUR_HEALTH --> EUR_REGISTRY[Verify Service Registry]
    
    CS_DEBUG --> CS_LOGS[Check Config Server Logs]
    CS_LOGS --> CS_GIT[Verify Git Access]
    CS_GIT --> CS_CONFIG[Test Configuration Retrieval]
    
    GW_DEBUG --> GW_LOGS[Check Gateway Logs]
    GW_LOGS --> GW_DEPS[Verify Dependencies]
    GW_DEPS --> GW_ROUTES[Test Route Configuration]
    
    CONN_DEBUG --> PING[Test Connectivity]
    PING --> DNS[Check DNS Resolution]
    DNS --> FIREWALL[Check Firewall Rules]
    
    EUR_REGISTRY --> SOLUTION[🎯 Solution Applied]
    CS_CONFIG --> SOLUTION
    GW_ROUTES --> SOLUTION
    FIREWALL --> SOLUTION
    
    style ISSUE fill:#ffcdd2
    style SOLUTION fill:#c8e6c9
```

### 🔍 Common Issues & Solutions

#### 1. Services not registering with Eureka
```bash
kubectl logs -n infrastructure eureka-server-0
# Check connectivity and configuration
```

#### 2. Config Server Git access issues
```bash
kubectl logs -n infrastructure config-server-0
# Verify Git repository URL and network access
```

#### 3. API Gateway startup failures
```bash
kubectl logs -n infrastructure api-gateway-0
# Check dependencies (Eureka, Config Server, Redis, Kafka)
```

### 🛠️ Useful Commands

```bash
# 📊 Check status
make status

# 📝 View logs
make logs

# 💊 Check health
make health

# 🔄 Restart services
make restart

# 🔗 Test connectivity
kubectl run -n infrastructure debug --image=busybox -it --rm -- sh
```

## 📈 Scaling

```mermaid
graph LR
    A[Current Scale] --> B{Load Increase?}
    B -->|Yes| C[Scale Up]
    B -->|No| D[Monitor]
    
    C --> C1[Scale Eureka to 3]
    C --> C2[Scale Gateway to 5]
    C --> C3[Scale Config Server to 2]
    
    C1 --> E[Update Resources]
    C2 --> E
    C3 --> E
    
    E --> F[Rolling Update]
    F --> D
    
    style A fill:#e3f2fd
    style C fill:#fff3e0
    style D fill:#e8f5e8
    style F fill:#f3e5f5
```

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

## 🗑️ Uninstallation

### 🧹 Complete Removal (⚠️ Data Loss)
```bash
# Using make
make clean

# Using script
./undeploy.sh -f
```

### 💾 Keep Data (Preserve PVCs)
```bash
./undeploy.sh -k
```

## 🛠️ Development

```mermaid
graph TD
    DEV[👨‍💻 Developer] --> LINT[🔍 Lint Chart]
    LINT --> TEST[🧪 Test Templates]
    TEST --> DEBUG[🐛 Debug Issues]
    DEBUG --> DOC[📝 Update Docs]
    DOC --> PR[🔄 Pull Request]
    
    style DEV fill:#e3f2fd
    style LINT fill:#e8f5e8
    style TEST fill:#fff3e0
    style DEBUG fill:#ffebee
    style DOC fill:#f3e5f5
    style PR fill:#e1f5fe
```

### 📝 Chart Development

```bash
# Lint the chart
make lint

# Test template rendering
make test

# Debug template issues
helm template nexus-infrastructure . -f values-dev.yaml --debug
```

## 🔗 Integration with Microservices

```mermaid
graph TB
    subgraph "Infrastructure Services"
        EUR[Eureka Server]
        CS[Config Server]
        GW[API Gateway]
        ZIP[Zipkin]
    end
    
    subgraph "Microservices"
        US[👤 User Service]
        PS[🛍️ Product Service]
        CRS[🛒 Cart Service]
        OS[📦 Order Service]
        PMS[💳 Payment Service]
        SS[🚚 Shipping Service]
        LS[🎁 Loyalty Service]
        NS[📧 Notification Service]
    end
    
    US -.->|registers with| EUR
    PS -.->|registers with| EUR
    CRS -.->|registers with| EUR
    OS -.->|registers with| EUR
    PMS -.->|registers with| EUR
    SS -.->|registers with| EUR
    LS -.->|registers with| EUR
    NS -.->|registers with| EUR
    
    US -.->|gets config from| CS
    PS -.->|gets config from| CS
    CRS -.->|gets config from| CS
    OS -.->|gets config from| CS
    
    GW -->|routes to| US
    GW -->|routes to| PS
    GW -->|routes to| CRS
    GW -->|routes to| OS
    GW -->|routes to| PMS
    
    US -.->|traces to| ZIP
    PS -.->|traces to| ZIP
    CRS -.->|traces to| ZIP
    OS -.->|traces to| ZIP
    PMS -.->|traces to| ZIP
    
    style EUR fill:#e1f5fe
    style CS fill:#f3e5f5
    style GW fill:#e8f5e8
    style ZIP fill:#fff3e0
```

This infrastructure chart provides the foundation for:

- 👤 **User Service** - Authentication and user management
- 🛍️ **Product Service** - Product catalog and inventory
- 🛒 **Cart Service** - Shopping cart functionality
- 📦 **Order Service** - Order processing and management
- 💳 **Payment Service** - Payment processing and validation
- 🚚 **Shipping Service** - Shipping and delivery tracking
- 🎁 **Loyalty Service** - Customer loyalty and rewards
- 📧 **Notification Service** - Event-driven notifications

## 🤝 Contributing

```mermaid
graph TD
    A[🍴 Fork Repository] --> B[🌿 Create Feature Branch]
    B --> C[💻 Make Changes]
    C --> D[🧪 Test Thoroughly]
    D --> E[📝 Update Documentation]
    E --> F[📤 Submit Pull Request]
    
    style A fill:#e3f2fd
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#ffebee
    style E fill:#f3e5f5
    style F fill:#e1f5fe
```

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Update documentation
5. Submit a pull request

## 📄 License

This chart is licensed under the MIT License. See LICENSE file for details.

## 🆘 Support

<div align="center">

[![Documentation](https://img.shields.io/badge/📖-Documentation-blue?style=for-the-badge)](https://docs.nexuscommerce.com)
[![GitHub Issues](https://img.shields.io/badge/🐛-Issues-red?style=for-the-badge)](https://github.com/nexuscommerce/helm-charts/issues)
[![Discord](https://img.shields.io/badge/💬-Discord-7289da?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/nexuscommerce)

</div>

---

<div align="center">

**Made with ❤️ by the NexusCommerce Team**

⭐ Star us on GitHub if this helped you!

</div>