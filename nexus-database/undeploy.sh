
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="data"
RELEASE_NAME="nexus-database"
FORCE=false
KEEP_PVCS=false
KEEP_NAMESPACE=false
BACKUP_FIRST=false

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
    echo "  -n, --namespace     Kubernetes namespace [default: data]"
    echo "  -r, --release       Helm release name [default: nexus-database]"
    echo "  -f, --force         Force deletion without confirmation"
    echo "  -k, --keep-pvcs     Keep PersistentVolumeClaims (preserve data)"
    echo "  --keep-namespace    Keep namespace after cleanup"
    echo "  --backup-first      Create backup before deletion (if backup is configured)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Interactive deletion"
    echo "  $0 -f                        # Force deletion"
    echo "  $0 -k                        # Keep data (PVCs)"
    echo "  $0 --backup-first -k         # Backup then keep data"
    echo ""
    echo "⚠️  WARNING: This will delete database deployments and potentially data!"
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
        --keep-namespace)
            KEEP_NAMESPACE=true
            shift
            ;;
        --backup-first)
            BACKUP_FIRST=true
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

print_message $BLUE "=== NexusCommerce Database Cleanup ==="
print_message $YELLOW "Namespace: $NAMESPACE"
print_message $YELLOW "Release: $RELEASE_NAME"

if [[ "$KEEP_PVCS" == true ]]; then
    print_message $YELLOW "PVCs will be preserved"
else
    print_message $RED "⚠️  PVCs will be deleted (data will be lost)"
fi

if [[ "$BACKUP_FIRST" == true ]]; then
    print_message $YELLOW "Backup will be created first"
fi

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    print_message $YELLOW "Namespace '$NAMESPACE' does not exist"
    exit 0
fi

# Show current resources
print_message $BLUE "Current resources in namespace '$NAMESPACE':"
kubectl get all -n "$NAMESPACE" 2>/dev/null || echo "No resources found"
echo ""
kubectl get pvc -n "$NAMESPACE" 2>/dev/null || echo "No PVCs found"

# Confirmation prompt
if [[ "$FORCE" == false ]]; then
    echo ""
    print_message $YELLOW "This will delete the NexusCommerce database deployment."
    if [[ "$KEEP_PVCS" == false ]]; then
        print_message $RED "⚠️  WARNING: All database data will be permanently lost!"
    fi
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message $BLUE "Operation cancelled."
        exit 0
    fi
fi

# Create backup if requested
if [[ "$BACKUP_FIRST" == true ]]; then
    print_message $BLUE "Creating backup before deletion..."

    # Check if backup CronJob exists
    if kubectl get cronjob backup-cronjob -n "$NAMESPACE" &> /dev/null; then
        # Trigger immediate backup
        JOB_NAME="manual-backup-$(date +%s)"
        kubectl create job "$JOB_NAME" --from=cronjob/backup-cronjob -n "$NAMESPACE"
        print_message $YELLOW "Backup job created: $JOB_NAME"
        print_message $YELLOW "Waiting for backup to complete..."
        kubectl wait --for=condition=complete job/"$JOB_NAME" -n "$NAMESPACE" --timeout=600s || {
            print_message $YELLOW "⚠️  Backup job did not complete within timeout"
            read -p "Continue with deletion anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_message $BLUE "Operation cancelled."
                exit 0
            fi
        }
        print_message $GREEN "✅ Backup completed"
    else
        print_message $YELLOW "⚠️  No backup CronJob found, skipping backup"
    fi
fi

# Stop any running port-forwards (best effort)
print_message $BLUE "Stopping any running port-forwards..."
pkill -f "kubectl.*port-forward.*$NAMESPACE" 2>/dev/null || true

# Scale down deployments gracefully
print_message $BLUE "Scaling down deployments..."
kubectl scale deployment --all --replicas=0 -n "$NAMESPACE" 2>/dev/null || true

# Wait a moment for graceful shutdown
sleep 5

# Check if helm release exists
if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
    print_message $BLUE "Uninstalling Helm release..."
    if helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"; then
        print_message $GREEN "✅ Helm release uninstalled"
    else
        print_message $YELLOW "⚠️  Helm uninstall encountered issues, continuing with manual cleanup"
    fi
else
    print_message $YELLOW "Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'"
fi

# Manual cleanup of remaining resources
print_message $BLUE "Cleaning up remaining resources..."

# Delete remaining deployments, statefulsets, services, etc.
kubectl delete deployment,statefulset,service,configmap,secret --all -n "$NAMESPACE" 2>/dev/null || true

# Delete PVCs if not keeping them
if [[ "$KEEP_PVCS" == false ]]; then
    print_message $BLUE "Deleting PersistentVolumeClaims..."
    if kubectl delete pvc --all -n "$NAMESPACE" 2>/dev/null; then
        print_message $GREEN "✅ PVCs deleted"
    else
        print_message $YELLOW "⚠️  Some PVCs could not be deleted (may be in use)"
    fi
else
    print_message $YELLOW "Keeping PVCs as requested"
    kubectl get pvc -n "$NAMESPACE" 2>/dev/null || true
fi

# Cleanup any remaining resources
print_message $BLUE "Final cleanup..."
kubectl delete job --all -n "$NAMESPACE" 2>/dev/null || true
kubectl delete cronjob --all -n "$NAMESPACE" 2>/dev/null || true

# Handle namespace deletion
if [[ "$KEEP_NAMESPACE" == false ]]; then
    if kubectl get all -n "$NAMESPACE" 2>/dev/null | grep -q "No resources found"; then
        if [[ "$FORCE" == true ]]; then
            print_message $BLUE "Deleting empty namespace..."
            kubectl delete namespace "$NAMESPACE" 2>/dev/null && print_message $GREEN "✅ Namespace deleted" || print_message $YELLOW "⚠️  Namespace deletion failed"
        else
            read -p "Namespace is empty. Delete it? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                kubectl delete namespace "$NAMESPACE" 2>/dev/null && print_message $GREEN "✅ Namespace deleted" || print_message $YELLOW "⚠️  Namespace deletion failed"
            fi
        fi
    else
        print_message $YELLOW "Namespace still contains resources, not deleting"
        kubectl get all -n "$NAMESPACE"
    fi
else
    print_message $YELLOW "Keeping namespace as requested"
fi

print_message $GREEN "🧹 Cleanup completed!"

# Show summary
echo ""
print_message $BLUE "=== Cleanup Summary ==="
if [[ "$KEEP_PVCS" == true ]]; then
    print_message $YELLOW "✅ Data preserved (PVCs kept)"
    echo "Remaining PVCs:"
    kubectl get pvc -n "$NAMESPACE" 2>/dev/null || echo "No PVCs found"
else
    print_message $YELLOW "❌ Data deleted (PVCs removed)"
fi

if [[ "$KEEP_NAMESPACE" == true ]]; then
    print_message $YELLOW "✅ Namespace preserved"
else
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_message $YELLOW "⚠️  Namespace still exists"
    else
        print_message $YELLOW "✅ Namespace deleted"
    fi
fi

echo ""
print_message $BLUE "=== Next Steps ==="
if [[ "$KEEP_PVCS" == true ]]; then
    echo "• To redeploy with existing data: make install ENVIRONMENT=<env>"
    echo "• To clean up data later: kubectl delete pvc --all -n $NAMESPACE"
else
    echo "• To redeploy fresh: make install ENVIRONMENT=<env>"
fi

if [[ "$BACKUP_FIRST" == true ]]; then
    echo "• Check backup status: kubectl get jobs -n $NAMESPACE"
    echo "• Backup data should be available for restore if needed"
fi