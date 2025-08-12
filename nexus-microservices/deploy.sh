#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
NAMESPACE="microservices"
RELEASE_NAME="nexus-microservices"
DRY_RUN=false
UPGRADE=false
WAIT_FOR_DEPENDENCIES=true

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment     Environment to deploy (dev|staging|prod) [default: dev]"
    echo "  -n, --namespace       Kubernetes namespace [default: microservices]"
    echo "  -r, --release         Helm release name [default: nexus-microservices]"
    echo "  -d, --dry-run         Perform a dry run"
    echo "  -u, --upgrade         Upgrade existing release"
    echo "  -s, --skip-deps       Skip dependency checks"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev                    # Deploy to development"
    echo "  $0 -e prod -u                # Upgrade production release"
    echo "  $0 -e staging -d             # Dry run for staging"
    echo "  $0 -e dev -s                 # Skip dependency checks"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -u|--upgrade)
            UPGRADE=true
            shift
            ;;
        -s|--skip-deps)
            WAIT_FOR_DEPENDENCIES=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_message $RED "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    print_message $RED "Error: Helm is not installed"
    exit 1
fi

# Check if kubectl is installed and configured
if ! command -v kubectl &> /dev/null; then
    print_message $RED "Error: kubectl is not installed"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    print_message $RED "Error: kubectl is not configured or cluster is not reachable"
    exit 1
fi

# Set values file based on environment
VALUES_FILE="values-${ENVIRONMENT}.yaml"

if [[ ! -f "$VALUES_FILE" ]]; then
    print_message $RED "Error: Values file $VALUES_FILE not found"
    exit 1
fi

print_message $BLUE "=== NexusCommerce Microservices Deployment ==="
print_message $YELLOW "Environment: $ENVIRONMENT"
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"
print_message $YELLOW "Values file: $VALUES_FILE"

# Check dependencies if not skipped
if [[ "$WAIT_FOR_DEPENDENCIES" == true ]]; then
    print_message $BLUE "Checking dependencies..."
    
    # Check if infrastructure namespace exists
    if ! kubectl get namespace infrastructure &> /dev/null; then
        print_message $RED "Error: Infrastructure namespace not found. Please deploy infrastructure first."
        print_message $YELLOW "Run: cd ../nexus-infrastructure && make $ENVIRONMENT"
        exit 1
    fi
    
    # Check if data namespace exists
    if ! kubectl get namespace data &> /dev/null; then
        print_message $RED "Error: Data namespace not found. Please deploy data layer first."
        print_message $YELLOW "Run: cd ../nexus-database && make $ENVIRONMENT"
        exit 1
    fi
    
    # Check key infrastructure services
    print_message $BLUE "Verifying infrastructure services..."
    
    if ! kubectl get svc eureka-server -n infrastructure &> /dev/null; then
        print_message $RED "Error: Eureka server not found in infrastructure namespace"
        exit 1
    fi
    
    if ! kubectl get svc config-server -n infrastructure &> /dev/null; then
        print_message $RED "Error: Config server not found in infrastructure namespace"
        exit 1
    fi
    
    # Check key data services
    print_message $BLUE "Verifying data services..."
    
    if ! kubectl get svc mongo-service -n data &> /dev/null; then
        print_message $YELLOW "Warning: MongoDB service not found in data namespace"
    fi
    
    if ! kubectl get svc postgres-service -n data &> /dev/null; then
        print_message $YELLOW "Warning: PostgreSQL service not found in data namespace"
    fi
    
    if ! kubectl get svc kafka-service -n data &> /dev/null; then
        print_message $YELLOW "Warning: Kafka service not found in data namespace"
    fi
    
    if ! kubectl get svc redis-service -n data &> /dev/null; then
        print_message $YELLOW "Warning: Redis service not found in data namespace"
    fi
    
    print_message $GREEN "✅ Dependencies verified"
fi

# Create namespace if it doesn't exist
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $YELLOW "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
    
    # Add Istio injection label if available
    if kubectl get namespace istio-system &> /dev/null; then
        kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
        print_message $GREEN "✅ Istio sidecar injection enabled"
    fi
fi

# Prepare helm command
HELM_CMD="helm"

if [[ "$UPGRADE" == true ]]; then
    HELM_CMD="$HELM_CMD upgrade"
else
    HELM_CMD="$HELM_CMD install"
fi

HELM_CMD="$HELM_CMD $RELEASE_NAME . -f $VALUES_FILE --namespace $NAMESPACE"

if [[ "$DRY_RUN" == true ]]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
    print_message $YELLOW "Running in dry-run mode..."
else
    HELM_CMD="$HELM_CMD --create-namespace"
fi

# Add environment-specific flags
case $ENVIRONMENT in
    prod)
        HELM_CMD="$HELM_CMD --timeout 20m0s --wait"
        ;;
    staging)
        HELM_CMD="$HELM_CMD --timeout 15m0s --wait"
        ;;
    dev)
        HELM_CMD="$HELM_CMD --timeout 10m0s"
        ;;
esac

# Execute helm command
print_message $BLUE "Executing: $HELM_CMD"
if eval "$HELM_CMD"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_message $GREEN "✅ Deployment successful!"
        print_message $BLUE "Checking deployment status..."

        # Wait for deployments to be ready
        kubectl rollout status deployment -n "$NAMESPACE" --timeout=600s 2>/dev/null || true

        print_message $GREEN "🚀 NexusCommerce Microservices are ready!"

        # Show connection information
        print_message $BLUE "\n=== Microservices Endpoints ==="
        echo "Internal Service URLs:"
        echo "  User Service: http://user-service.$NAMESPACE.svc.cluster.local:8081"
        echo "  Product Service: http://product-service.$NAMESPACE.svc.cluster.local:8082"
        echo "  Cart Service: http://cart-service.$NAMESPACE.svc.cluster.local:8082"
        echo "  Order Service: http://order-service.$NAMESPACE.svc.cluster.local:8082"
        echo "  Payment Service: http://payment-service.$NAMESPACE.svc.cluster.local:8084"
        echo "  Notification Service: http://notification-service.$NAMESPACE.svc.cluster.local:8086"
        echo "  Loyalty Service: http://loyalty-service.$NAMESPACE.svc.cluster.local:8084"
        echo "  Shipping Service: http://shipping-service.$NAMESPACE.svc.cluster.local:8085"
        echo ""
        echo "Health Check URLs:"
        echo "  User Service: http://user-service.$NAMESPACE.svc.cluster.local:8081/api/users/actuator/health"
        echo "  Product Service: http://product-service.$NAMESPACE.svc.cluster.local:8082/api/products/actuator/health"
        echo "  Cart Service: http://cart-service.$NAMESPACE.svc.cluster.local:8082/api/carts/actuator/health"
        echo "  Order Service: http://order-service.$NAMESPACE.svc.cluster.local:8082/actuator/health"
        echo "  Payment Service: http://payment-service.$NAMESPACE.svc.cluster.local:8084/health"
        echo "  Notification Service: http://notification-service.$NAMESPACE.svc.cluster.local:8086/actuator/health"
        echo "  Loyalty Service: http://loyalty-service.$NAMESPACE.svc.cluster.local:8084/api/loyalty/actuator/health"
        echo "  Shipping Service: http://shipping-service.$NAMESPACE.svc.cluster.local:8085/health"
        
        if [[ "$ENVIRONMENT" == "dev" ]]; then
            print_message $BLUE "\n=== Development Access (NodePort) ==="
            echo "External access via NodePort:"
            echo "  User Service: http://localhost:30081"
            echo "  Product Service: http://localhost:30082"
            echo "  Cart Service: http://localhost:30083"
            echo "  Order Service: http://localhost:30084"
            echo "  Payment Service: http://localhost:30085"
            echo "  Notification Service: http://localhost:30086"
            echo "  Loyalty Service: http://localhost:30087"
            echo "  Shipping Service: http://localhost:30088"
        fi
    else
        print_message $GREEN "✅ Dry run completed successfully!"
    fi
else
    print_message $RED "❌ Deployment failed!"
    print_message $YELLOW "Checking pod status for troubleshooting..."
    kubectl get pods -n "$NAMESPACE" || true
    print_message $YELLOW "Checking events for issues..."
    kubectl get events -n "$NAMESPACE" --sort-by=.metadata.creationTimestamp || true
    exit 1
fi