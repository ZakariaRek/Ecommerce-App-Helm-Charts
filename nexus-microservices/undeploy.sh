#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="microservices"
RELEASE_NAME="nexus-microservices"
FORCE=false
KEEP_DATA=false
DRY_RUN=false

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
    echo "  -n, --namespace       Kubernetes namespace [default: microservices]"
    echo "  -r, --release         Helm release name [default: nexus-microservices]"
    echo "  -f, --force           Force deletion (delete PVCs and secrets)"
    echo "  -k, --keep-data       Keep persistent data (PVCs)"
    echo "  -d, --dry-run         Show what would be deleted without actually deleting"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Remove release but keep data"
    echo "  $0 -f                 # Force remove everything including data"
    echo "  $0 -k                 # Keep persistent volumes"
    echo "  $0 -d                 # Dry run to see what would be deleted"
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
        -k|--keep-data)
            KEEP_DATA=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
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

print_message $BLUE "=== NexusCommerce Microservices Removal ==="
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"
print_message $YELLOW "Force deletion: $FORCE"
print_message $YELLOW "Keep data: $KEEP_DATA"
print_message $YELLOW "Dry run: $DRY_RUN"

# Check if release exists
if ! helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    print_message $YELLOW "Warning: Release $RELEASE_NAME not found in namespace $NAMESPACE"
    
    # Check if namespace has any resources
    if kubectl get all -n "$NAMESPACE" &> /dev/null; then
        print_message $YELLOW "But namespace $NAMESPACE exists with resources. Checking for orphaned resources..."
        kubectl get all -n "$NAMESPACE"
    else
        print_message $GREEN "Namespace $NAMESPACE does not exist or is empty. Nothing to clean up."
        exit 0
    fi
else
    print_message $BLUE "Found release $RELEASE_NAME in namespace $NAMESPACE"
fi

if [[ "$DRY_RUN" == true ]]; then
    print_message $YELLOW "=== DRY RUN MODE - No actual changes will be made ==="
    
    # Show what would be deleted
    print_message $BLUE "Would uninstall Helm release:"
    helm list -n "$NAMESPACE" | grep "$RELEASE_NAME" || true
    
    print_message $BLUE "Would delete these resources:"
    kubectl get all -n "$NAMESPACE" -l app.kubernetes.io/instance="$RELEASE_NAME" || true
    
    if [[ "$FORCE" == true ]]; then
        print_message $BLUE "Would force delete PVCs:"
        kubectl get pvc -n "$NAMESPACE" || true
        
        print_message $BLUE "Would delete secrets:"
        kubectl get secrets -n "$NAMESPACE" -l app.kubernetes.io/instance="$RELEASE_NAME" || true
    fi
    
    print_message $GREEN "✅ Dry run completed successfully!"
    exit 0
fi

# Confirmation prompt unless force is specified
if [[ "$FORCE" == false ]]; then
    print_message $YELLOW "Are you sure you want to remove the NexusCommerce microservices?"
    print_message $YELLOW "This will delete the Helm release and associated resources."
    if [[ "$KEEP_DATA" == false ]]; then
        print_message $RED "WARNING: This will also delete persistent data!"
    fi
    read -p "Type 'yes' to confirm: " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        print_message $GREEN "Aborted by user"
        exit 0
    fi
fi

# Scale down deployments gracefully
print_message $BLUE "Scaling down deployments..."
kubectl scale deployment --all --replicas=0 -n "$NAMESPACE" || true

# Wait for pods to terminate
print_message $BLUE "Waiting for pods to terminate..."
kubectl wait --for=delete pod --all -n "$NAMESPACE" --timeout=120s || true

# Uninstall Helm release
print_message $BLUE "Uninstalling Helm release $RELEASE_NAME..."
if helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"; then
    print_message $GREEN "✅ Helm release uninstalled successfully"
else
    print_message $RED "❌ Failed to uninstall Helm release"
    exit 1
fi

# Remove additional resources if force is enabled
if [[ "$FORCE" == true ]]; then
    print_message $BLUE "Force deletion enabled - removing additional resources..."
    
    # Delete PVCs if not keeping data
    if [[ "$KEEP_DATA" == false ]]; then
        print_message $BLUE "Deleting persistent volume claims..."
        kubectl delete pvc --all -n "$NAMESPACE" --ignore-not-found=true
        print_message $GREEN "✅ PVCs deleted"
    else
        print_message $YELLOW "Keeping persistent volume claims"
    fi
    
    # Delete secrets
    print_message $BLUE "Deleting secrets..."
    kubectl delete secrets -l app.kubernetes.io/instance="$RELEASE_NAME" -n "$NAMESPACE" --ignore-not-found=true
    print_message $GREEN "✅ Secrets deleted"
    
    # Delete configmaps
    print_message $BLUE "Deleting configmaps..."
    kubectl delete configmaps -l app.kubernetes.io/instance="$RELEASE_NAME" -n "$NAMESPACE" --ignore-not-found=true
    print_message $GREEN "✅ ConfigMaps deleted"
    
    # Delete ingress resources
    print_message $BLUE "Deleting ingress resources..."
    kubectl delete ingress --all -n "$NAMESPACE" --ignore-not-found=true
    print_message $GREEN "✅ Ingress resources deleted"
    
    # Delete service monitors (if they exist)
    kubectl delete servicemonitor --all -n "$NAMESPACE" --ignore-not-found=true 2>/dev/null || true
fi

# Clean up orphaned resources
print_message $BLUE "Cleaning up any orphaned resources..."

# Delete any remaining pods
kubectl delete pods --all -n "$NAMESPACE" --ignore-not-found=true --force --grace-period=0 || true

# Delete any remaining services
kubectl delete services --all -n "$NAMESPACE" --ignore-not-found=true || true

# Check if namespace is empty and should be deleted
remaining_resources=$(kubectl get all -n "$NAMESPACE" 2>/dev/null | wc -l)
if [[ $remaining_resources -le 1 ]]; then  # Only header line remains
    print_message $BLUE "Namespace appears empty. Would you like to delete it? (y/n)"
    read -p "Delete namespace $NAMESPACE? " delete_ns
    
    if [[ "$delete_ns" =~ ^[Yy]$ ]]; then
        kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
        print_message $GREEN "✅ Namespace $NAMESPACE deleted"
    fi
else
    print_message $YELLOW "Namespace $NAMESPACE still contains resources:"
    kubectl get all -n "$NAMESPACE" || true
fi

print_message $GREEN "🎉 NexusCommerce microservices removal completed!"

# Show final status
print_message $BLUE "\n=== Final Status ==="
print_message $BLUE "Checking for remaining Helm releases..."
helm list -n "$NAMESPACE" | grep "$RELEASE_NAME" || print_message $GREEN "No releases found"

if kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $BLUE "Remaining resources in namespace $NAMESPACE:"
    kubectl get all -n "$NAMESPACE" || print_message $GREEN "No resources found"
else
    print_message $GREEN "Namespace $NAMESPACE has been deleted"
fi

print_message $GREEN "✅ Cleanup completed successfully!"
