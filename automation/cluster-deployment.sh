#!/bin/bash
# Multi-Cluster Deployment Automation
# This script demonstrates automating deployments across multiple Kubernetes clusters

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_SCRIPT="${SCRIPT_DIR}/kubectl-ai-auto.sh"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Multi-Cluster Deployment Automation ===${NC}"
echo ""

# Function to deploy to a specific cluster
deploy_to_cluster() {
    local cluster_name="$1"
    local context="$2"
    
    echo -e "${YELLOW}Deploying to cluster: ${cluster_name} (context: ${context})${NC}"
    
    # Switch kubectl context
    kubectl config use-context "${context}"
    
    # Run deployment automation
    "${AUTO_SCRIPT}" "deploy nginx with 3 replicas and expose on port 80 in production namespace"
    
    # Verify deployment
    "${AUTO_SCRIPT}" "verify nginx deployment is running successfully in production namespace"
    
    echo -e "${GREEN}Deployment to ${cluster_name} complete${NC}"
    echo ""
}

# Check if automation script exists
if [ ! -f "${AUTO_SCRIPT}" ]; then
    echo "Error: Automation script not found at ${AUTO_SCRIPT}"
    exit 1
fi

# Make automation script executable
chmod +x "${AUTO_SCRIPT}"

# Initialize automation configuration
"${AUTO_SCRIPT}" --init

# Example: Deploy to multiple clusters
# Modify the cluster names and contexts to match your environment
# Uncomment the lines below and adjust for your clusters

# deploy_to_cluster "development" "dev-cluster-context"
# deploy_to_cluster "staging" "staging-cluster-context"
# deploy_to_cluster "production" "prod-cluster-context"

echo -e "${BLUE}=== Multi-Cluster Deployment Complete ===${NC}"
echo ""
echo "To use this script with your clusters:"
echo "1. Uncomment and modify the deploy_to_cluster calls"
echo "2. Replace cluster names and contexts with your actual values"
echo "3. Run: ./cluster-deployment.sh"
