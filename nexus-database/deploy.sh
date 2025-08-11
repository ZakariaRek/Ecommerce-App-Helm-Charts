set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
NAMESPACE="data"
RELEASE_NAME="nexus-database"
DRY_RUN=false
UPGRADE=false
FORCE=false
WAIT=true
DEBUG=false

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
    echo "  -e, --environment   Environment to deploy (dev|staging|prod) [default: dev]"
    echo "  -n, --namespace     Kubernetes namespace [default: data]"
    echo "  -r, --release       Helm release name [default: nexus-database]"
    echo "  -d, --dry-run       Perform a dry run"
    echo "  -u, --upgrade       Upgrade existing release"
    echo "  -f, --force         Force upgrade/install"
    echo "  --no-wait           Don't wait for deployment to complete"
    echo "  --debug             Enable debug output"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev                    # Deploy to development"
    echo "  $0 -e prod -u                # Upgrade production release"
    echo "  $0 -e staging -d             # Dry run for staging"
    echo "  $0 -e prod -u --force        # Force upgrade production"
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
        -f|--force)
            FORCE=true
            shift
            ;;
        --no-wait)
            WAIT=false
            shift
            ;;
        --debug)
            DEBUG=true
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

print_message $BLUE "=== NexusCommerce Database Deployment ==="
print_message $YELLOW "Environment: $ENVIRONMENT"
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"
print_message $YELLOW "Values file: $VALUES_FILE"
print_message $YELLOW "Upgrade mode: $UPGRADE"
print_message $YELLOW "Dry run: $DRY_RUN"

# Check if release exists for upgrade validation
RELEASE_EXISTS=false
if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
    RELEASE_EXISTS=true
    print_message $YELLOW "Existing release found: $RELEASE_NAME"
fi

# Auto-detect upgrade if release exists and upgrade not explicitly set
if [[ "$RELEASE_EXISTS" == true && "$UPGRADE" == false ]]; then
    print_message $YELLOW "Release exists, automatically switching to upgrade mode"
    UPGRADE=true
fi

# Create namespace if it doesn't exist
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $YELLOW "Creating namespace: $NAMESPACE"
    if [[ "$DRY_RUN" == false ]]; then
        kubectl create namespace "$NAMESPACE"
    fi
fi

# Prepare helm command
HELM_CMD="helm"

if [[ "$UPGRADE" == true ]]; then
    HELM_CMD="$HELM_CMD upgrade"
    if [[ "$RELEASE_EXISTS" == false ]]; then
        HELM_CMD="$HELM_CMD --install"
    fi
else
    HELM_CMD="$HELM_CMD install"
fi

HELM_CMD="$HELM_CMD $RELEASE_NAME . -f $VALUES_FILE --namespace $NAMESPACE"

# Add common flags
if [[ "$DRY_RUN" == true ]]; then
    HELM_CMD="$HELM_CMD --dry-run"
    if [[ "$DEBUG" == true ]]; then
        HELM_CMD="$HELM_CMD --debug"
    fi
    print_message $YELLOW "Running in dry-run mode..."
else
    HELM_CMD="$HELM_CMD --create-namespace"
fi

# Add force flag if specified
if [[ "$FORCE" == true ]]; then
    HELM_CMD="$HELM_CMD --force"
    print_message $YELLOW "Force mode enabled"
fi

# Add wait flag based on preference
if [[ "$WAIT" == true && "$DRY_RUN" == false ]]; then
    HELM_CMD="$HELM_CMD --wait"
fi

# Add environment-specific flags
case $ENVIRONMENT in
    prod)
        HELM_CMD="$HELM_CMD --timeout 15m0s"
        if [[ "$WAIT" == true ]]; then
            HELM_CMD="$HELM_CMD --wait-for-jobs"
        fi
        ;;
    staging)
        HELM_CMD="$HELM_CMD --timeout 10m0s"
        ;;
    dev)
        HELM_CMD="$HELM_CMD --timeout 5m0s"
        ;;
esac

# Add debug flag if enabled
if [[ "$DEBUG" == true ]]; then
    HELM_CMD="$HELM_CMD --debug"
fi

# Pre-deployment validation
if [[ "$DRY_RUN" == false ]]; then
    print_message $BLUE "Running pre-deployment validation..."
    
    # Validate the chart
    if ! helm lint . -f "$VALUES_FILE" >/dev/null 2>&1; then
        print_message $RED "❌ Chart validation failed"
        print_message $YELLOW "Running helm lint for details:"
        helm lint . -f "$VALUES_FILE"
        exit 1
    fi
    
    # Test template rendering
    if ! helm template "$RELEASE_NAME" . -f "$VALUES_FILE" --namespace "$NAMESPACE" >/dev/null 2>&1; then
        print_message $RED "❌ Template rendering failed"
        exit 1
    fi
    
    print_message $GREEN "✅ Pre-deployment validation passed"
fi

# Execute helm command
print_message $BLUE "Executing: $HELM_CMD"
if eval "$HELM_CMD"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_message $GREEN "✅ Deployment successful!"
        
        if [[ "$WAIT" == true ]]; then
            print_message $BLUE "Checking deployment status..."
            
            # Wait for deployments to be ready
            print_message $YELLOW "Waiting for deployments..."
            kubectl rollout status deployment -n "$NAMESPACE" --timeout=300s 2>/dev/null || true
            
            print_message $YELLOW "Waiting for statefulsets..."
            kubectl rollout status statefulset -n "$NAMESPACE" --timeout=300s 2>/dev/null || true
            
            # Check pod status
            print_message $BLUE "Pod Status:"
            kubectl get pods -n "$NAMESPACE" -o wide
        fi
        
        print_message $GREEN "🚀 NexusCommerce Database is ready!"
        
        # Show connection information
        print_message $BLUE "\n=== Connection Information ==="
        echo "MongoDB URLs:"
        echo "  Cart: mongodb://cart-mongodb-headless.$NAMESPACE.svc.cluster.local:27017/cartdb"
        echo "  User: mongodb://user-mongodb-headless.$NAMESPACE.svc.cluster.local:27017/userdb"
        echo ""
        echo "PostgreSQL URLs:"
        echo "  Product: product-postgres-service.$NAMESPACE.svc.cluster.local:5432/productdb"
        echo "  Payment: payment-postgres-service.$NAMESPACE.svc.cluster.local:5432/paymentdb"
        echo "  Order: order-postgres-service.$NAMESPACE.svc.cluster.local:5432/orderdb"
        echo "  Loyalty: loyalty-postgres-service.$NAMESPACE.svc.cluster.local:5432/loyalty-service"
        echo "  Shipping: shipping-postgres-service.$NAMESPACE.svc.cluster.local:5432/shippingdb"
        echo ""
        echo "Redis URL:"
        echo "  redis-service.$NAMESPACE.svc.cluster.local:6379"
        echo ""
        echo "Kafka URL:"
        echo "  kafka-service.$NAMESPACE.svc.cluster.local:9092"
        echo ""
        print_message $BLUE "=== Useful Commands ==="
        echo "Check status: kubectl get all -n $NAMESPACE"
        echo "View logs: kubectl logs -n $NAMESPACE -l tier=database"
        echo "Port forward Redis: kubectl port-forward -n $NAMESPACE svc/redis-service 6379:6379"
        
        # Environment-specific notes
        case $ENVIRONMENT in
            prod)
                print_message $YELLOW "\n⚠️  Production Deployment Notes:"
                echo "- Verify backup schedules are working"
                echo "- Check monitoring and alerting"
                echo "- Validate security configurations"
                echo "- Review resource utilization"
                ;;
            staging)
                print_message $YELLOW "\n📋 Staging Deployment Notes:"
                echo "- Run integration tests"
                echo "- Verify data migration scripts"
                echo "- Test backup and restore procedures"
                ;;
            dev)
                print_message $YELLOW "\n🔧 Development Deployment Notes:"
                echo "- Use 'make logs' to view application logs"
                echo "- Use 'make port-forward' for local access"
                echo "- Database credentials are default/insecure"
                ;;
        esac
        
    else
        print_message $GREEN "✅ Dry run completed successfully!"
        print_message $BLUE "Review the output above and run without --dry-run to deploy"
    fi
else
    print_message $RED "❌ Deployment failed!"
    print_message $YELLOW "Troubleshooting tips:"
    echo "1. Check cluster resources: kubectl top nodes"
    echo "2. Check events: kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
    echo "3. Check pod status: kubectl get pods -n $NAMESPACE"
    echo "4. View detailed logs: kubectl describe pods -n $NAMESPACE"
    exit 1
fi