#!/bin/bash
# Complete Automation Workflow Example
# This script demonstrates a full end-to-end automated deployment workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_SCRIPT="${SCRIPT_DIR}/../kubectl-ai-auto.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  kubectl-ai Complete Automation Workflow Example      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Initialize automation
echo -e "${YELLOW}Step 1: Initializing automation configuration...${NC}"
"${AUTO_SCRIPT}" --init
echo -e "${GREEN}✓ Automation initialized${NC}"
echo ""

# Step 2: Pre-deployment checks
echo -e "${YELLOW}Step 2: Running pre-deployment checks...${NC}"
"${AUTO_SCRIPT}" "check if the cluster is ready and all nodes are healthy"
echo -e "${GREEN}✓ Pre-deployment checks completed${NC}"
echo ""

# Step 3: Create namespace if needed
echo -e "${YELLOW}Step 3: Ensuring namespace exists...${NC}"
"${AUTO_SCRIPT}" "create namespace demo-automation if it doesn't exist"
echo -e "${GREEN}✓ Namespace ready${NC}"
echo ""

# Step 4: Deploy application
echo -e "${YELLOW}Step 4: Deploying application...${NC}"
"${AUTO_SCRIPT}" "deploy nginx with 3 replicas in demo-automation namespace using latest stable image"
echo -e "${GREEN}✓ Application deployed${NC}"
echo ""

# Step 5: Create service
echo -e "${YELLOW}Step 5: Creating service...${NC}"
"${AUTO_SCRIPT}" "create a LoadBalancer service for nginx in demo-automation namespace exposing port 80"
echo -e "${GREEN}✓ Service created${NC}"
echo ""

# Step 6: Verify deployment
echo -e "${YELLOW}Step 6: Verifying deployment...${NC}"
"${AUTO_SCRIPT}" "check if all nginx pods in demo-automation namespace are running and ready"
echo -e "${GREEN}✓ Deployment verified${NC}"
echo ""

# Step 7: Get deployment info
echo -e "${YELLOW}Step 7: Getting deployment information...${NC}"
"${AUTO_SCRIPT}" "show me the service endpoint for nginx in demo-automation namespace"
echo -e "${GREEN}✓ Deployment information retrieved${NC}"
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Automation workflow completed successfully!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  • Visit the service endpoint to verify nginx is running"
echo "  • Scale the deployment: ${AUTO_SCRIPT} \"scale nginx to 5 replicas in demo-automation\""
echo "  • Clean up: ${AUTO_SCRIPT} \"delete namespace demo-automation\""
echo ""
echo -e "${YELLOW}Tip:${NC} You can modify this script to match your deployment needs!"
