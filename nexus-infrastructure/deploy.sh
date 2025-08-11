
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
NAMESPACE="infrastructure"
RELEASE_NAME="nexus-infrastructure"
DRY_RUN=false
UPGRADE=false

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
    echo "  -n, --namespace     Kubernetes namespace [default: infrastructure]"
    echo "  -r, --release       Helm release name [default: nexus-infrastructure]"
    echo "  -d, --dry-run       Perform a dry run"
    echo "  -u, --upgrade       Upgrade existing release"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev                    # Deploy to development"
    echo "  $0 -e prod -u                # Upgrade production release"
    echo "  $0 -e staging -d             # Dry run for staging"
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

print_message $BLUE "=== NexusCommerce Infrastructure Deployment ==="
print_message $YELLOW "Environment: $ENVIRONMENT"
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"
print_message $YELLOW "Values file: $VALUES_FILE"

# Create namespace if it doesn't exist
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $YELLOW "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
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
        HELM_CMD="$HELM_CMD --timeout 15m0s --wait"
        ;;
    staging)
        HELM_CMD="$HELM_CMD --timeout 10m0s --wait"
        ;;
    dev)
        HELM_CMD="$HELM_CMD --timeout 5m0s"
        ;;
esac

# Execute helm command
print_message $BLUE "Executing: $HELM_CMD"
if eval "$HELM_CMD"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_message $GREEN "✅ Deployment successful!"
        print_message $BLUE "Checking deployment status..."

        # Wait for deployments to be ready
        kubectl rollout status deployment -n "$NAMESPACE" --timeout=300s 2>/dev/null || true

        print_message $GREEN "🚀 NexusCommerce Infrastructure is ready!"

        # Show connection information
        print_message $BLUE "\n=== Connection Information ==="
        echo "Service Endpoints:"
        echo "  Eureka Server: http://eureka-server.$NAMESPACE.svc.cluster.local:8761"
        echo "  Config Server: http://config-server.$NAMESPACE.svc.cluster.local:8888"
        echo "  API Gateway: http://api-gateway.$NAMESPACE.svc.cluster.local:8099"
        echo "  Zipkin: http://zipkin-server.$NAMESPACE.svc.cluster.local:9411"
        echo ""
        echo "Health Check URLs:"
        echo "  Eureka: http://eureka-server.$NAMESPACE.svc.cluster.local:8761/actuator/health"
        echo "  Config Server: http://config-server.$NAMESPACE.svc.cluster.local:8888/actuator/health"
        echo "  API Gateway: http://api-gateway.$NAMESPACE.svc.cluster.local:8099/actuator/health"
        echo "  Zipkin: http://zipkin-server.$NAMESPACE.svc.cluster.local:9411/health"
    else
        print_message $GREEN "✅ Dry run completed successfully!"
    fi
else
    print_message $RED "❌ Deployment failed!"
    exit 1
fi