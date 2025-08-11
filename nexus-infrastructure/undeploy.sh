
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="infrastructure"
RELEASE_NAME="nexus-infrastructure"
FORCE=false
KEEP_PVCS=false

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
    echo "  -n, --namespace     Kubernetes namespace [default: infrastructure]"
    echo "  -r, --release       Helm release name [default: nexus-infrastructure]"
    echo "  -f, --force         Force deletion without confirmation"
    echo "  -k, --keep-pvcs     Keep PersistentVolumeClaims (preserve data)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Interactive deletion"
    echo "  $0 -f                        # Force deletion"
    echo "  $0 -k                        # Keep data (PVCs)"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -k|--keep-pvcs)
            KEEP_PVCS=true
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

print_message $BLUE "=== NexusCommerce Infrastructure Cleanup ==="
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"

if [[ "$KEEP_PVCS" == true ]]; then
    print_message $YELLOW "PVCs will be preserved"
else
    print_message $RED "⚠️  PVCs will be deleted (data will be lost)"
fi

# Confirmation prompt
if [[ "$FORCE" == false ]]; then
    print_message $YELLOW "\nThis will delete the NexusCommerce infrastructure deployment."
    if [[ "$KEEP_PVCS" == false ]]; then
        print_message $RED "WARNING: All infrastructure data will be permanently lost!"
    fi
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message $BLUE "Operation cancelled."
        exit 0
    fi
fi

# Check if helm release exists
if ! helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    print_message $YELLOW "Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
else
    print_message $BLUE "Uninstalling Helm release..."
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
    print_message $GREEN "✅ Helm release uninstalled"
fi

# Delete PVCs if not keeping them
if [[ "$KEEP_PVCS" == false ]]; then
    print_message $BLUE "Deleting PersistentVolumeClaims..."
    kubectl delete pvc -n "$NAMESPACE" --all 2>/dev/null || true
    print_message $GREEN "✅ PVCs deleted"
else
    print_message $YELLOW "Keeping PVCs as requested"
fi

# Clean up cluster-scoped resources
print_message $BLUE "Cleaning up RBAC resources..."
kubectl delete clusterrole ingress-nginx-clusterrole 2>/dev/null || true
kubectl delete clusterrolebinding ingress-nginx-clusterrolebinding 2>/dev/null || true
print_message $GREEN "✅ RBAC resources cleaned up"

# Optionally delete namespace if empty
if kubectl get all -n "$NAMESPACE" 2>/dev/null | grep -q "No resources found"; then
    if [[ "$FORCE" == true ]]; then
        kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
        print_message $GREEN "✅ Empty namespace deleted"
    else
        read -p "Namespace is empty. Delete it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
            print_message $GREEN "✅ Namespace deleted"
        fi
    fi
fi

print_message $GREEN "🧹 Cleanup completed!"

