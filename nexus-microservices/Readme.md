# NexusCommerce Microservices Helm Chart

[![Helm Version](https://img.shields.io/badge/Helm-v3.8+-blue?logo=helm&logoColor=white)](https://helm.sh/)
[![Kubernetes Version](https://img.shields.io/badge/Kubernetes-v1.20+-blue?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker&logoColor=white)](https://docker.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7+-green?logo=spring&logoColor=white)](https://spring.io/projects/spring-boot)
[![Go](https://img.shields.io/badge/Go-1.19+-00ADD8?logo=go&logoColor=white)](https://golang.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Enabled-green?logo=mongodb&logoColor=white)](https://mongodb.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Enabled-blue?logo=postgresql&logoColor=white)](https://postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-Enabled-red?logo=redis&logoColor=white)](https://redis.io/)
[![Apache Kafka](https://img.shields.io/badge/Kafka-Enabled-black?logo=apache-kafka&logoColor=white)](https://kafka.apache.org/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Dashboards-orange?logo=grafana&logoColor=white)](https://grafana.com/)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Helm chart for deploying the complete NexusCommerce microservices ecosystem including User Management, Product Catalog, Shopping Cart, Order Processing, Payment Processing, Notifications, Loyalty Program, and Shipping Management.

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "External Traffic"
        Client[👤 Client Applications]
        Web[🌐 Web Frontend]
        Mobile[📱 Mobile App]
    end

    subgraph "Infrastructure Layer"
        Gateway[🚪 API Gateway<br/>Port 8080]
        Eureka[🔍 Service Discovery<br/>Eureka Server]
        Config[⚙️ Config Server<br/>Port 8888]
        Zipkin[📊 Distributed Tracing<br/>Zipkin]
    end

    subgraph "Microservices Layer"
        User[👥 User Service<br/>Port 8081<br/>• Authentication<br/>• User Profiles<br/>• OAuth2/JWT]
        Product[📦 Product Service<br/>Port 8082<br/>• Product CRUD<br/>• Search & Filter<br/>• Categories]
        Cart[🛒 Cart Service<br/>Port 8082<br/>• Session Mgmt<br/>• Cart Persist<br/>• Item Mgmt]
        Order[📋 Order Service<br/>Port 8082<br/>• Order Processing<br/>• Workflows<br/>• History]
        Payment[💳 Payment Service<br/>Port 8084<br/>• Stripe/PayPal<br/>• Secure Trans<br/>• Fraud Detect]
        Notification[📢 Notification Service<br/>Port 8086<br/>• Email/SMS<br/>• Real-time<br/>• Templates]
        Loyalty[🎁 Loyalty Service<br/>Port 8084<br/>• Points System<br/>• Tier Mgmt<br/>• Rewards]
        Shipping[🚚 Shipping Service<br/>Port 8085<br/>• GPS Tracking<br/>• Real-time Loc<br/>• Delivery Mgmt]
    end

    subgraph "Data Layer"
        MongoDB[(🍃 MongoDB<br/>User, Cart, Notification)]
        PostgreSQL[(🐘 PostgreSQL<br/>Product, Order, Payment<br/>Loyalty, Shipping)]
        Redis[(⚡ Redis<br/>Cache & Sessions)]
        Kafka[📨 Apache Kafka<br/>Event Streaming]
    end

    subgraph "Monitoring & Observability"
        Prometheus[📊 Prometheus<br/>Metrics Collection]
        Grafana[📈 Grafana<br/>Dashboards]
        AlertManager[🚨 Alert Manager<br/>Notifications]
    end

    %% External connections
    Client --> Gateway
    Web --> Gateway
    Mobile --> Gateway

    %% Gateway routing
    Gateway --> User
    Gateway --> Product
    Gateway --> Cart
    Gateway --> Order
    Gateway --> Payment
    Gateway --> Notification
    Gateway --> Loyalty
    Gateway --> Shipping

    %% Service discovery
    User -.-> Eureka
    Product -.-> Eureka
    Cart -.-> Eureka
    Order -.-> Eureka
    Payment -.-> Eureka
    Notification -.-> Eureka
    Loyalty -.-> Eureka
    Shipping -.-> Eureka

    %% Configuration
    User -.-> Config
    Product -.-> Config
    Cart -.-> Config
    Order -.-> Config
    Payment -.-> Config
    Notification -.-> Config
    Loyalty -.-> Config
    Shipping -.-> Config

    %% Data connections
    User --> MongoDB
    Cart --> MongoDB
    Notification --> MongoDB
    Product --> PostgreSQL
    Order --> PostgreSQL
    Payment --> PostgreSQL
    Loyalty --> PostgreSQL
    Shipping --> PostgreSQL
    
    Cart --> Redis
    Order --> Redis
    Payment --> Redis
    Loyalty --> Redis

    %% Event streaming
    User --> Kafka
    Product --> Kafka
    Cart --> Kafka
    Order --> Kafka
    Payment --> Kafka
    Notification --> Kafka
    Loyalty --> Kafka
    Shipping --> Kafka

    %% Monitoring
    User -.-> Prometheus
    Product -.-> Prometheus
    Cart -.-> Prometheus
    Order -.-> Prometheus
    Payment -.-> Prometheus
    Notification -.-> Prometheus
    Loyalty -.-> Prometheus
    Shipping -.-> Prometheus
    
    Prometheus --> Grafana
    Prometheus --> AlertManager

    %% Tracing
    User -.-> Zipkin
    Product -.-> Zipkin
    Cart -.-> Zipkin
    Order -.-> Zipkin
    Payment -.-> Zipkin
    Notification -.-> Zipkin
    Loyalty -.-> Zipkin
    Shipping -.-> Zipkin

    classDef serviceClass fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef dataClass fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef infraClass fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef monitorClass fill:#fff3e0,stroke:#e65100,stroke-width:2px

    class User,Product,Cart,Order,Payment,Notification,Loyalty,Shipping serviceClass
    class MongoDB,PostgreSQL,Redis,Kafka dataClass
    class Gateway,Eureka,Config,Zipkin infraClass
    class Prometheus,Grafana,AlertManager monitorClass
```

## 🔄 Service Dependencies Flow

```mermaid
graph LR
    subgraph "Core Services"
        User[👥 User Service<br/>Authentication Hub]
        Product[📦 Product Service<br/>Catalog Management]
    end
    
    subgraph "Business Logic"
        Cart[🛒 Cart Service]
        Order[📋 Order Service]
        Payment[💳 Payment Service]
    end
    
    subgraph "Support Services"
        Notification[📢 Notification Service]
        Loyalty[🎁 Loyalty Service]
        Shipping[🚚 Shipping Service]
    end

    %% Primary dependencies
    Cart --> User
    Cart --> Product
    Order --> User
    Order --> Product
    Order --> Cart
    Payment --> Order
    Shipping --> Order
    
    %% Notification dependencies
    Notification --> User
    Notification --> Order
    Notification --> Payment
    Notification --> Shipping
    
    %% Loyalty dependencies
    Loyalty --> User
    Loyalty --> Order

    classDef coreService fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef businessService fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef supportService fill:#e8f5e8,stroke:#388e3c,stroke-width:2px

    class User,Product coreService
    class Cart,Order,Payment businessService
    class Notification,Loyalty,Shipping supportService
```

## 🚀 Deployment Flow

```mermaid
graph TD
    Start([🚀 Start Deployment]) --> CheckDeps{📋 Check Dependencies}
    CheckDeps -->|Missing| InstallInfra[🏗️ Install Infrastructure<br/>• Eureka Server<br/>• Config Server<br/>• API Gateway<br/>• Zipkin]
    CheckDeps -->|Missing| InstallData[💾 Install Data Layer<br/>• MongoDB<br/>• PostgreSQL<br/>• Redis<br/>• Kafka]
    CheckDeps -->|Ready| DeployCore[🔧 Deploy Core Services]
    
    InstallInfra --> WaitInfra[⏳ Wait for Infrastructure]
    InstallData --> WaitData[⏳ Wait for Data Services]
    WaitInfra --> DeployCore
    WaitData --> DeployCore
    
    DeployCore --> User[👥 Deploy User Service]
    User --> Product[📦 Deploy Product Service]
    Product --> Cart[🛒 Deploy Cart Service]
    Cart --> Order[📋 Deploy Order Service]
    Order --> Payment[💳 Deploy Payment Service]
    Payment --> Notification[📢 Deploy Notification Service]
    Notification --> Loyalty[🎁 Deploy Loyalty Service]
    Loyalty --> Shipping[🚚 Deploy Shipping Service]
    
    Shipping --> HealthCheck{🏥 Health Check}
    HealthCheck -->|Failed| Debug[🐛 Debug Issues]
    HealthCheck -->|Passed| ConfigIngress[🌐 Configure Ingress]
    Debug --> HealthCheck
    
    ConfigIngress --> SetupMonitoring[📊 Setup Monitoring]
    SetupMonitoring --> Complete([✅ Deployment Complete])

    classDef startEnd fill:#4caf50,stroke:#2e7d32,stroke-width:2px,color:white
    classDef process fill:#2196f3,stroke:#1976d2,stroke-width:2px,color:white
    classDef decision fill:#ff9800,stroke:#f57c00,stroke-width:2px,color:white
    classDef service fill:#9c27b0,stroke:#7b1fa2,stroke-width:2px,color:white

    class Start,Complete startEnd
    class InstallInfra,InstallData,DeployCore,WaitInfra,WaitData,ConfigIngress,SetupMonitoring,Debug process
    class CheckDeps,HealthCheck decision
    class User,Product,Cart,Order,Payment,Notification,Loyalty,Shipping service
```

## 📊 Service Communication Patterns

```mermaid
sequenceDiagram
    participant Client
    participant Gateway as API Gateway
    participant User as User Service
    participant Product as Product Service
    participant Cart as Cart Service
    participant Order as Order Service
    participant Payment as Payment Service
    participant Notification as Notification Service
    participant Kafka as Event Bus

    Note over Client,Kafka: Complete E-commerce Flow

    Client->>Gateway: 1. Login Request
    Gateway->>User: Authenticate User
    User-->>Gateway: JWT Token
    Gateway-->>Client: Authentication Success

    Client->>Gateway: 2. Browse Products
    Gateway->>Product: Get Product Catalog
    Product-->>Gateway: Product List
    Gateway-->>Client: Products Data

    Client->>Gateway: 3. Add to Cart
    Gateway->>Cart: Add Item (with JWT)
    Cart->>User: Validate User Session
    Cart->>Product: Verify Product Details
    Cart-->>Gateway: Cart Updated
    Gateway-->>Client: Item Added

    Client->>Gateway: 4. Checkout
    Gateway->>Order: Create Order
    Order->>Cart: Get Cart Items
    Order->>Product: Validate Products
    Order->>User: Verify User Details
    Order-->>Gateway: Order Created
    Gateway-->>Client: Order Confirmation

    Client->>Gateway: 5. Process Payment
    Gateway->>Payment: Process Payment
    Payment->>Order: Validate Order
    Payment-->>Gateway: Payment Success
    Gateway-->>Client: Payment Confirmed

    Note over Kafka: Asynchronous Events

    Payment->>Kafka: PaymentConfirmed Event
    Order->>Kafka: OrderCompleted Event
    
    Kafka->>Notification: Send Confirmation Email
    Kafka->>Notification: Send SMS Update
    
    Notification->>Client: Email Sent
    Notification->>Client: SMS Sent

    Note over Client,Kafka: Background Processing
    Kafka->>Order: Update Order Status
    Kafka->>Cart: Clear Cart Items
```

## 📋 Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| ![Kubernetes](https://img.shields.io/badge/Kubernetes-1.20+-326ce5?logo=kubernetes&logoColor=white) | 1.20+ | Container orchestration |
| ![Helm](https://img.shields.io/badge/Helm-3.8+-0f1689?logo=helm&logoColor=white) | 3.8+ | Package management |
| ![Resources](https://img.shields.io/badge/RAM-8GB+-red) | 8GB+ | Minimum cluster memory |
| ![CPU](https://img.shields.io/badge/CPU-4%20Cores+-blue) | 4 Cores+ | Minimum cluster CPU |

### 🔗 Required Dependencies

```mermaid
graph LR
    subgraph "Dependencies Installation Order"
        A[1️⃣ Data Layer<br/>nexus-database] --> B[2️⃣ Infrastructure<br/>nexus-infrastructure]
        B --> C[3️⃣ Microservices<br/>nexus-microservices]
    end
    
    subgraph "Data Layer Components"
        D[MongoDB<br/>User, Cart, Notifications]
        E[PostgreSQL<br/>Product, Order, Payment<br/>Loyalty, Shipping]
        F[Redis<br/>Cache & Sessions]
        G[Kafka<br/>Event Streaming]
    end
    
    subgraph "Infrastructure Components"
        H[Eureka Server<br/>Service Discovery]
        I[Config Server<br/>Configuration]
        J[API Gateway<br/>Request Routing]
        K[Zipkin<br/>Distributed Tracing]
    end
    
    A -.-> D
    A -.-> E
    A -.-> F
    A -.-> G
    
    B -.-> H
    B -.-> I
    B -.-> J
    B -.-> K

    classDef layer fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef component fill:#f3e5f5,stroke:#4a148c,stroke-width:1px

    class A,B,C layer
    class D,E,F,G,H,I,J,K component
```

## 🚀 Quick Start

### 1️⃣ Deploy Dependencies

```bash
# Deploy the database layer
cd ../nexus-database
make dev

# Deploy the infrastructure layer
cd ../nexus-infrastructure
make dev
```

### 2️⃣ Deploy Microservices

```bash
# Development deployment
make dev

# Or using deployment script
./deploy.sh -e dev

# Or using helm directly
helm install nexus-microservices . -f values-dev.yaml \
  --namespace microservices --create-namespace
```

### 3️⃣ Production Deployment

```bash
# Production deployment
make prod

# Or with upgrade capability
./deploy.sh -e prod -u
```

## ⚙️ Environment Configurations

```mermaid
graph LR
    subgraph "Development"
        Dev[🛠️ Development<br/>• Single replicas<br/>• NodePort access<br/>• Debug logging<br/>• Relaxed security]
    end
    
    subgraph "Staging"
        Stage[🧪 Staging<br/>• 2 replicas<br/>• Load testing<br/>• Performance monitoring<br/>• Mock external services]
    end
    
    subgraph "Production"
        Prod[🏭 Production<br/>• 3+ replicas<br/>• High availability<br/>• Enhanced security<br/>• Full monitoring]
    end

    Dev --> Stage
    Stage --> Prod

    classDef env fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    class Dev,Stage,Prod env
```

| Environment | Replicas | Resources | Purpose |
|-------------|----------|-----------|---------|
| **dev** | Minimal (1) | Low | Development & testing |
| **staging** | Medium (2) | Medium | Pre-production testing |
| **prod** | High (2-3) | High | Production workloads |

## 🛠️ Service Configuration

### Core Services

<details>
<summary><strong>👥 User Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `userService.enabled` | Enable User Service | `true` |
| `userService.replicas` | Number of replicas | `2` |
| `userService.config.contextPath` | API context path | `/api/users` |
| `userService.config.database.name` | MongoDB database name | `User-service` |
| `userService.config.jwt.expirationMs` | JWT expiration time | `86400000` |

**Features:**
- 🔐 JWT Authentication
- 👤 User Profile Management
- 🔄 OAuth2 Integration
- 📊 Activity Tracking

</details>

<details>
<summary><strong>📦 Product Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `productService.enabled` | Enable Product Service | `true` |
| `productService.replicas` | Number of replicas | `2` |
| `productService.config.contextPath` | API context path | `/api/products` |
| `productService.config.database.name` | PostgreSQL database name | `productdb` |

**Features:**
- 🏪 Product Catalog Management
- 🔍 Advanced Search & Filtering
- 📂 Category Management
- 🖼️ Image Upload Support

</details>

<details>
<summary><strong>🛒 Cart Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cartService.enabled` | Enable Cart Service | `true` |
| `cartService.replicas` | Number of replicas | `2` |
| `cartService.config.contextPath` | API context path | `/api/carts` |
| `cartService.config.sessionTimeout` | Cart session timeout (seconds) | `1800` |
| `cartService.config.cacheTimeout` | Cache timeout (seconds) | `600` |

**Features:**
- 🛍️ Shopping Cart Management
- ⏱️ Session Persistence
- 💾 Redis Caching
- 🔄 Auto-cleanup

</details>

<details>
<summary><strong>📋 Order Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `orderService.enabled` | Enable Order Service | `true` |
| `orderService.replicas` | Number of replicas | `2` |
| `orderService.config.database.name` | PostgreSQL database name | `orderdb` |

**Features:**
- 📝 Order Processing
- 🔄 Workflow Management
- 📊 Order History
- 📈 Status Tracking

</details>

### Business Services

<details>
<summary><strong>💳 Payment Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `paymentService.enabled` | Enable Payment Service | `true` |
| `paymentService.replicas` | Number of replicas | `2` |
| `paymentService.config.features.stripe` | Enable Stripe payments | `true` |
| `paymentService.config.features.paypal` | Enable PayPal payments | `false` |
| `paymentService.config.security.maxPaymentAmount` | Maximum payment amount | `10000.00` |

**Features:**
- 💎 Stripe Integration
- 🌐 PayPal Support
- 🔒 PCI Compliance Ready
- 🛡️ Fraud Detection
- 💰 Refund Processing

</details>

<details>
<summary><strong>📢 Notification Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `notificationService.enabled` | Enable Notification Service | `true` |
| `notificationService.replicas` | Number of replicas | `2` |
| `notificationService.config.features.email` | Enable email notifications | `true` |
| `notificationService.config.features.sms` | Enable SMS notifications | `false` |
| `notificationService.config.features.websocket` | Enable WebSocket notifications | `false` |

**Features:**
- 📧 Email Notifications
- 📱 SMS Support
- 🔄 Real-time WebSockets
- 📋 Template Management

</details>

### Support Services

<details>
<summary><strong>🎁 Loyalty Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `loyaltyService.enabled` | Enable Loyalty Service | `true` |
| `loyaltyService.replicas` | Number of replicas | `2` |
| `loyaltyService.config.contextPath` | API context path | `/api/loyalty` |
| `loyaltyService.config.tiers.goldThreshold` | Points for Gold tier | `2000` |
| `loyaltyService.config.points.orderRate` | Points per dollar spent | `1.0` |

**Features:**
- 🏆 Tier Management (Bronze → Diamond)
- 💎 Points System
- 🎊 Rewards Program
- 🎟️ Coupon Management

</details>

<details>
<summary><strong>🚚 Shipping Service</strong></summary>

| Parameter | Description | Default |
|-----------|-------------|---------|
| `shippingService.enabled` | Enable Shipping Service | `true` |
| `shippingService.replicas` | Number of replicas | `1` |
| `shippingService.config.features.gpsTracking` | Enable GPS tracking | `true` |
| `shippingService.config.features.realTimeLocation` | Enable real-time location | `true` |

**Features:**
- 📍 GPS Tracking
- 🗺️ Real-time Location Updates
- 📦 Delivery Management
- 📊 Logistics Analytics

</details>

## 🌐 Service Endpoints

### Internal Service URLs

```mermaid
graph LR
    subgraph "Kubernetes Cluster"
        subgraph "Microservices Namespace"
            A[user-service<br/>:8081] 
            B[product-service<br/>:8082]
            C[cart-service<br/>:8082]
            D[order-service<br/>:8082]
            E[payment-service<br/>:8084]
            F[notification-service<br/>:8086]
            G[loyalty-service<br/>:8084]
            H[shipping-service<br/>:8085]
        end
    end

    classDef service fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    class A,B,C,D,E,F,G,H service
```

| Service | Internal URL | API Context |
|---------|-------------|------------|
| 👥 **User** | `http://user-service.microservices.svc.cluster.local:8081` | `/api/users` |
| 📦 **Product** | `http://product-service.microservices.svc.cluster.local:8082` | `/api/products` |
| 🛒 **Cart** | `http://cart-service.microservices.svc.cluster.local:8082` | `/api/carts` |
| 📋 **Order** | `http://order-service.microservices.svc.cluster.local:8082` | `/api/orders` |
| 💳 **Payment** | `http://payment-service.microservices.svc.cluster.local:8084` | `/api/payments` |
| 📢 **Notification** | `http://notification-service.microservices.svc.cluster.local:8086` | `/api/notifications` |
| 🎁 **Loyalty** | `http://loyalty-service.microservices.svc.cluster.local:8084` | `/api/loyalty` |
| 🚚 **Shipping** | `http://shipping-service.microservices.svc.cluster.local:8085` | `/api/shipping` |

### 🏥 Health Check URLs

```bash
# Check individual service health
curl http://user-service.microservices.svc.cluster.local:8081/api/users/actuator/health
curl http://product-service.microservices.svc.cluster.local:8082/api/products/actuator/health
curl http://cart-service.microservices.svc.cluster.local:8082/api/carts/actuator/health
curl http://order-service.microservices.svc.cluster.local:8082/actuator/health
curl http://payment-service.microservices.svc.cluster.local:8084/health
curl http://notification-service.microservices.svc.cluster.local:8086/actuator/health
curl http://loyalty-service.microservices.svc.cluster.local:8084/api/loyalty/actuator/health
curl http://shipping-service.microservices.svc.cluster.local:8085/health
```

## 🌐 Development Access

### NodePort Access (Development)

```mermaid
graph TB
    subgraph "External Access (Development)"
        Dev[💻 Developer Machine<br/>localhost]
    end
    
    subgraph "Kubernetes Cluster"
        subgraph "NodePort Services"
            U[👥 User Service<br/>:30081]
            P[📦 Product Service<br/>:30082]
            C[🛒 Cart Service<br/>:30083]
            O[📋 Order Service<br/>:30084]
            Pay[💳 Payment Service<br/>:30085]
            N[📢 Notification Service<br/>:30086]
            L[🎁 Loyalty Service<br/>:30087]
            S[🚚 Shipping Service<br/>:30088]
        end
    end

    Dev -.-> U
    Dev -.-> P
    Dev -.-> C
    Dev -.-> O
    Dev -.-> Pay
    Dev -.-> N
    Dev -.-> L
    Dev -.-> S

    classDef external fill:#4caf50,stroke:#2e7d32,stroke-width:2px,color:white
    classDef nodeport fill:#ff9800,stroke:#f57c00,stroke-width:2px,color:white

    class Dev external
    class U,P,C,O,Pay,N,L,S nodeport
```

| Service | Development URL | Production URL |
|---------|-----------------|----------------|
| 👥 User | `http://localhost:30081` | `https://api.nexuscommerce.com/api/users` |
| 📦 Product | `http://localhost:30082` | `https://api.nexuscommerce.com/api/products` |
| 🛒 Cart | `http://localhost:30083` | `https://api.nexuscommerce.com/api/carts` |
| 📋 Order | `http://localhost:30084` | `https://api.nexuscommerce.com/api/orders` |
| 💳 Payment | `http://localhost:30085` | `https://api.nexuscommerce.com/api/payments` |
| 📢 Notification | `http://localhost:30086` | `https://api.nexuscommerce.com/api/notifications` |
| 🎁 Loyalty | `http://localhost:30087` | `https://api.nexuscommerce.com/api/loyalty` |
| 🚚 Shipping | `http://localhost:30088` | `https://api.nexuscommerce.com/api/shipping` |

### Port Forwarding Setup

```bash
# Set up port forwarding for all services
make port-forward

# Individual port forwarding
kubectl port-forward -n microservices svc/user-service 8081:8081
kubectl port-forward -n microservices svc/product-service 8082:8082
kubectl port-forward -n microservices svc/payment-service 8085:8084
```

## 📊 Monitoring & Observability

```mermaid
graph TB
    subgraph "Observability Stack"
        subgraph "Metrics Collection"
            Prom[📊 Prometheus<br/>Metrics Server]
            SM[🎯 ServiceMonitor<br/>Auto-discovery]
        end
        
        subgraph "Visualization"
            Graf[📈 Grafana<br/>Dashboards]
            Alert[🚨 AlertManager<br/>Notifications]
        end
        
        subgraph "Tracing"
            Zipkin[🔍 Zipkin<br/>Distributed Tracing]
            Jaeger[🕸️ Jaeger<br/>Alternative Tracing]
        end
        
        subgraph "Logging"
            ELK[📝 ELK Stack<br/>Log Aggregation]
            Fluent[🌊 Fluentd<br/>Log Shipping]
        end
    end
    
    subgraph "Microservices"
        Services[🔧 All Services<br/>Actuator Endpoints]
    end

    Services --> Prom
    Services --> Zipkin
    Services --> Fluent
    
    SM --> Prom
    Prom --> Graf
    Prom --> Alert
    Zipkin -.-> Jaeger
    Fluent --> ELK

    classDef metrics fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef viz fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef trace fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef logs fill:#fff3e0,stroke:#f57c00,stroke-width:2px

    class Prom,SM metrics
    class Graf,Alert viz
    class Zipkin,Jaeger trace
    class ELK,Fluent logs
```

### Monitoring Features

- **📊 Prometheus Metrics**: Automatic collection from all services
- **📈 Grafana Dashboards**: Pre-configured business and technical dashboards
- **🚨 Alert Rules**: Production-ready alerting for critical issues
- **🔍 Distributed Tracing**: Request tracking across services
- **🏥 Health Checks**: Comprehensive health monitoring

## 🔐 Security Configuration

```mermaid
graph TB
    subgraph "Security Layers"
        subgraph "Network Security"
            NP[🛡️ Network Policies<br/>Pod-to-Pod Rules]
            Ingress[🌐 Ingress Controller<br/>TLS Termination]
        end
        
        subgraph "Authentication & Authorization"
            JWT[🔐 JWT Tokens<br/>Service Authentication]
            RBAC[👤 RBAC<br/>Kubernetes Permissions]
        end
        
        subgraph "Data Security"
            Secrets[🔒 Kubernetes Secrets<br/>Credential Management]
            Encrypt[🔐 Data Encryption<br/>Payment & PII Data]
        end
        
        subgraph "Service Mesh Security"
            mTLS[🔗 mTLS<br/>Service-to-Service]
            Istio[🕸️ Istio<br/>Zero Trust Network]
        end
    end

    classDef network fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef auth fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef mesh fill:#fff3e0,stroke:#f57c00,stroke-width:2px

    class NP,Ingress network
    class JWT,RBAC auth
    class Secrets,Encrypt data
    class mTLS,Istio mesh
```

### Security Features by Environment

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| **Network Policies** | ❌ Disabled | ❌ Disabled | ✅ Enabled |
| **TLS/SSL** | ❌ HTTP Only | ✅ Let's Encrypt | ✅ Valid Certificates |
| **RBAC** | ✅ Basic | ✅ Enhanced | ✅ Strict |
| **Pod Security** | ❌ Relaxed | ✅ Standard | ✅ Restricted |
| **Secret Management** | ✅ Basic | ✅ Encrypted | ✅ Vault Integration |
| **Service Mesh** | ❌ Disabled | ✅ Optional | ✅ mTLS Enabled |

## 📈 Scaling & Performance

### Horizontal Pod Autoscaling

```mermaid
graph LR
    subgraph "Scaling Triggers"
        CPU[💻 CPU > 70%]
        Memory[💾 Memory > 80%]
        Custom[📊 Custom Metrics]
    end
    
    subgraph "HPA Controller"
        HPA[⚖️ HPA<br/>Decision Engine]
    end
    
    subgraph "Scaling Actions"
        ScaleUp[📈 Scale Up<br/>Add Pods]
        ScaleDown[📉 Scale Down<br/>Remove Pods]
    end
    
    CPU --> HPA
    Memory --> HPA
    Custom --> HPA
    
    HPA --> ScaleUp
    HPA --> ScaleDown

    classDef trigger fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef controller fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef action fill:#e8f5e8,stroke:#388e3c,stroke-width:2px

    class CPU,Memory,Custom trigger
    class HPA controller
    class ScaleUp,ScaleDown action
```

### Scaling Configuration

```bash
# Enable autoscaling
helm upgrade nexus-microservices . \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10 \
  --namespace microservices

# Manual scaling
make scale SERVICE=user-service REPLICAS=5

# Check scaling status
kubectl get hpa -n microservices
```

## 🚨 Troubleshooting

### Common Issues & Solutions

<details>
<summary><strong>🔴 Services not registering with Eureka</strong></summary>

```bash
# Check Eureka connectivity
kubectl logs -n microservices user-service-0

# Verify Eureka server status
kubectl get svc -n infrastructure eureka-server

# Test connectivity from pod
kubectl exec -n microservices user-service-0 -- nc -zv eureka-server.infrastructure.svc.cluster.local 8761
```

</details>

<details>
<summary><strong>🔴 Database connection failures</strong></summary>

```bash
# Check database service status
kubectl get svc -n data

# Verify PostgreSQL/MongoDB pods
kubectl get pods -n data -l app=postgres
kubectl get pods -n data -l app=mongodb

# Test database connectivity
kubectl exec -n microservices product-service-0 -- nc -zv postgres-service.data.svc.cluster.local 5432
```

</details>

<details>
<summary><strong>🔴 Payment service startup failures</strong></summary>

```bash
# Check payment service logs
kubectl logs -n microservices payment-service-0

# Verify secrets
kubectl get secrets -n microservices payment-service-secrets -o yaml

# Check Stripe API connectivity (if enabled)
kubectl exec -n microservices payment-service-0 -- curl -s https://api.stripe.com/v1
```

</details>

### Useful Commands

```bash
# Check all microservices status
make status

# View logs for all microservices
make logs

# View logs for specific service
make logs-user
make logs-payment

# Check service health
make health

# Restart all services
make restart

# Debug specific service
make debug SERVICE=payment-service

# Test connectivity from within cluster
kubectl run -n microservices debug --image=busybox -it --rm -- sh
```

## 🔄 Deployment Order

```mermaid
graph TD
    subgraph "Phase 1: Infrastructure"
        A[🏗️ Data Layer<br/>MongoDB, PostgreSQL<br/>Redis, Kafka]
        B[⚙️ Infrastructure<br/>Eureka, Config Server<br/>API Gateway, Zipkin]
    end
    
    subgraph "Phase 2: Core Services"
        C[👥 User Service<br/>Authentication Provider]
        D[📦 Product Service<br/>Catalog Management]
    end
    
    subgraph "Phase 3: Business Logic"
        E[🛒 Cart Service]
        F[📋 Order Service]
        G[💳 Payment Service]
    end
    
    subgraph "Phase 4: Support Services"
        H[📢 Notification Service]
        I[🎁 Loyalty Service]
        J[🚚 Shipping Service]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    G --> I
    G --> J

    classDef infra fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef core fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef business fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef support fill:#fff3e0,stroke:#f57c00,stroke-width:2px

    class A,B infra
    class C,D core
    class E,F,G business
    class H,I,J support
```

## 📝 API Documentation

Each service exposes comprehensive API documentation:

| Service | Swagger UI | OpenAPI Spec |
|---------|------------|-------------|
| 👥 **User** | `/api/users/swagger-ui.html` | `/api/users/v3/api-docs` |
| 📦 **Product** | `/api/products/swagger-ui.html` | `/api/products/v3/api-docs` |
| 🛒 **Cart** | `/api/carts/swagger-ui.html` | `/api/carts/v3/api-docs` |
| 📋 **Order** | `/actuator/swagger-ui.html` | `/v3/api-docs` |
| 💳 **Payment** | `/docs` | `/docs/json` |
| 📢 **Notification** | `/actuator/swagger-ui.html` | `/v3/api-docs` |
| 🎁 **Loyalty** | `/api/loyalty/swagger-ui.html` | `/api/loyalty/v3/api-docs` |
| 🚚 **Shipping** | `/docs` | `/docs/json` |

## 🧪 Testing

### Load Testing

```bash
# Install dependencies for testing
helm install nexus-microservices . -f values-dev.yaml

# Run load tests with k6
kubectl apply -f tests/load-tests.yaml

# Check test results
kubectl logs -l app=load-tests
```

### Integration Testing

```bash
# Run integration tests
kubectl apply -f tests/integration-tests.yaml

# Monitor test progress
kubectl logs -f -l app=integration-tests
```

## 🗑️ Uninstallation

### Complete Removal ⚠️ (Data Loss)

```bash
# Using make
make clean

# Using script with force deletion
./undeploy.sh -f

# Using helm directly
helm uninstall nexus-microservices -n microservices
kubectl delete namespace microservices
```

### Keep Data (Preserve PVCs)

```bash
# Preserve persistent volumes
./undeploy.sh -k
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💻 Make your changes and test thoroughly
4. 📝 Update documentation
5. 🚀 Submit a pull request

### Adding New Microservices

1. Add configuration to `values.yaml`
2. Create templates in `templates/service-name/` directory
3. Update `_helpers.tpl` with new labels
4. Add health checks and init containers
5. Test with `helm template`
6. Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **📚 Documentation**: [docs.nexuscommerce.com](https://docs.nexuscommerce.com)
- **🐛 Issues**: [GitHub Issues](https://github.com/nexuscommerce/helm-charts/issues)
- **💬 Discord**: [NexusCommerce Community](https://discord.gg/nexuscommerce)
- **📧 Email**: support@nexuscommerce.com

## 🗺️ Roadmap

```mermaid
gantt
    title NexusCommerce Microservices Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1
    Service Mesh Integration    :active, p1, 2024-01-01, 2024-03-31
    Advanced Monitoring        :active, p2, 2024-02-01, 2024-04-30
    
    section Phase 2
    GraphQL Federation         :p3, 2024-04-01, 2024-06-30
    Event Sourcing            :p4, 2024-05-01, 2024-07-31
    
    section Phase 3
    Multi-region Deployment   :p5, 2024-07-01, 2024-09-30
    Chaos Engineering        :p6, 2024-08-01, 2024-10-31
    
    section Phase 4
    AI/ML Integration         :p7, 2024-10-01, 2024-12-31
    Advanced Security         :p8, 2024-11-01, 2025-01-31
```

- ✅ **Q1 2024**: Service mesh complete integration
- 🔄 **Q2 2024**: Advanced monitoring and alerting
- 📋 **Q3 2024**: GraphQL federation gateway
- 🎯 **Q4 2024**: Event sourcing implementation
- 🚀 **2025**: Multi-region deployment support

---

<div align="center">

**⭐ Star this repository if it helped you!**

[![GitHub stars](https://img.shields.io/github/stars/nexuscommerce/helm-charts?style=social)](https://github.com/nexuscommerce/helm-charts)
[![GitHub forks](https://img.shields.io/github/forks/nexuscommerce/helm-charts?style=social)](https://github.com/nexuscommerce/helm-charts/fork)
[![GitHub watchers](https://img.shields.io/github/watchers/nexuscommerce/helm-charts?style=social)](https://github.com/nexuscommerce/helm-charts)

Made with ❤️ by the [NexusCommerce Team](https://github.com/nexuscommerce)

</div>