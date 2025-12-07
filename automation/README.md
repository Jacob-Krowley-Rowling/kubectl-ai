# kubectl-ai Automation Guide

This guide explains how to use kubectl-ai's automation capabilities for streamlined, hands-free Kubernetes operations with automatic iteration and MCP (Model Context Protocol) integration.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Multi-Cluster Automation](#multi-cluster-automation)
- [MCP Integration](#mcp-integration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

kubectl-ai automation mode enables fully automated Kubernetes operations with:

- **Auto-approval**: Skips all confirmation prompts (use `--skip-permissions`)
- **Auto-iteration**: Automatically retries and refines operations up to max iterations
- **MCP Client Mode**: Integrates with custom MCP servers for enhanced capabilities
- **Batch Processing**: Execute multiple operations from files
- **Multi-Cluster Support**: Automate deployments across multiple clusters

## Features

### Core Automation Capabilities

1. **Automatic Confirmation** - No manual intervention required for operations
2. **Intelligent Iteration** - AI iterates automatically to achieve desired state
3. **MCP Integration** - Use custom tools and capabilities via MCP servers
4. **Batch Execution** - Run multiple operations from task files
5. **Cluster Orchestration** - Deploy across multiple clusters seamlessly

### Safety Features

While automation removes manual confirmations, kubectl-ai maintains safety through:

- Configurable max iterations to prevent infinite loops
- Verbose logging for audit trails
- Exit codes for automation workflow integration
- Dry-run capabilities (when supported by underlying tools)

## Quick Start

### 1. Build kubectl-ai

```bash
cd /path/to/kubectl-ai
make build
```

### 2. Initialize Automation

```bash
./automation/kubectl-ai-auto.sh --init
```

This creates:
- `~/.config/kubectl-ai/automation.yaml` - Automation configuration
- Ensures MCP configuration is set up

### 3. Run Your First Automated Task

```bash
./automation/kubectl-ai-auto.sh "list all pods in default namespace"
```

## Configuration

### Automation Configuration

File: `~/.config/kubectl-ai/automation.yaml`

```yaml
# Auto-approve all operations (skip permission prompts)
skipPermissions: true

# Maximum iterations for agent processing
maxIterations: 20

# Enable MCP client mode for enhanced capabilities
mcpClient: true

# Enable external MCP tools discovery
externalTools: true

# LLM provider configuration
llmProvider: gemini

# Default model
model: gemini-2.5-flash-preview-04-17

# Quiet mode for non-interactive automation
quiet: true

# Show tool output in terminal
showToolOutput: true

# Verbose logging level (0=none, 1=info, 2=debug)
verboseLevel: 1
```

### MCP Configuration

File: `~/.config/kubectl-ai/mcp.yaml`

```yaml
servers:
  # Sequential thinking for advanced reasoning
  - name: sequential-thinking
    command: npx
    args:
      - -y
      - "@modelcontextprotocol/server-sequential-thinking"
  
  # Add your custom MCP servers here
  # Example remote MCP server:
  # - name: custom-api
  #   url: https://api.example.com/mcp
  #   auth:
  #     type: bearer
  #     token: "${MCP_TOKEN}"
```

## Usage Examples

### Single Command Automation

```bash
# Deploy an application
./automation/kubectl-ai-auto.sh "deploy nginx with 3 replicas in production namespace"

# Scale a deployment
./automation/kubectl-ai-auto.sh "scale nginx deployment to 5 replicas"

# Check cluster health
./automation/kubectl-ai-auto.sh "check health of all nodes and report any issues"
```

### Batch Automation

Create a task file (`tasks.txt`):

```text
# Deployment tasks
create namespace myapp if it doesn't exist
deploy redis in myapp namespace
create a service for redis exposing port 6379
deploy myapp with 3 replicas in myapp namespace
create an ingress for myapp pointing to the service
```

Run batch automation:

```bash
./automation/kubectl-ai-auto.sh --batch tasks.txt
```

### Custom Iterations

For complex operations that may require more iterations:

```bash
./automation/kubectl-ai-auto.sh --iterations 30 "diagnose and fix all failing pods in production namespace"
```

### Verbose Mode

For detailed logging and debugging:

```bash
./automation/kubectl-ai-auto.sh --verbose 2 "deploy complex multi-tier application"
```

## Multi-Cluster Automation

### Using the Cluster Deployment Script

Edit `automation/cluster-deployment.sh` to configure your clusters:

```bash
# Add your cluster configurations
deploy_to_cluster "development" "dev-cluster-context"
deploy_to_cluster "staging" "staging-cluster-context"
deploy_to_cluster "production" "prod-cluster-context"
```

Run multi-cluster deployment:

```bash
chmod +x automation/cluster-deployment.sh
./automation/cluster-deployment.sh
```

### Manual Multi-Cluster Operations

```bash
# Switch context and deploy
kubectl config use-context dev-cluster
./automation/kubectl-ai-auto.sh "deploy myapp in development namespace"

kubectl config use-context prod-cluster
./automation/kubectl-ai-auto.sh "deploy myapp in production namespace with 5 replicas"
```

## MCP Integration

### Using Custom MCP Servers

The automation script automatically enables MCP client mode (`--mcp-client` flag), which:

1. Connects to all configured MCP servers in `~/.config/kubectl-ai/mcp.yaml`
2. Discovers available tools from each server
3. Makes these tools available to the AI agent

### Adding Custom MCP Servers

Edit `~/.config/kubectl-ai/mcp.yaml`:

```yaml
servers:
  # Local MCP server
  - name: my-custom-tools
    command: /path/to/my-mcp-server
    args:
      - --config
      - /path/to/config.json
    env:
      API_KEY: "${MY_API_KEY}"
  
  # Remote MCP server
  - name: cloud-automation
    url: https://automation.example.com/mcp
    auth:
      type: bearer
      token: "${CLOUD_TOKEN}"
```

### MCP Server Examples

**Sequential Thinking** (default):
- Advanced reasoning and step-by-step analysis
- Automatically included in default configuration

**Custom Tools**:
- Add your organization-specific automation tools
- Database management tools
- Cloud provider integrations
- Monitoring and alerting systems

## Best Practices

### 1. Test First in Safe Environments

```bash
# Test in development first
kubectl config use-context dev
./automation/kubectl-ai-auto.sh "deploy new-feature"

# Then promote to production
kubectl config use-context prod
./automation/kubectl-ai-auto.sh "deploy new-feature"
```

### 2. Use Descriptive Task Files

```text
# Good: Specific and clear
create namespace app-prod if not exists
deploy app version 2.1.0 with 3 replicas in app-prod

# Avoid: Vague or ambiguous
do stuff with app
fix everything
```

### 3. Monitor Automation Logs

The automation script provides colored output:
- 🔵 INFO: General information
- 🟢 SUCCESS: Successful operations
- 🟡 WARNING: Non-critical issues
- 🔴 ERROR: Failures

Save logs for audit:

```bash
./automation/kubectl-ai-auto.sh "deploy app" 2>&1 | tee deployment.log
```

### 4. Set Appropriate Iteration Limits

- Simple operations: 10-20 iterations (default: 20)
- Complex operations: 30-50 iterations
- Troubleshooting: 50+ iterations

```bash
./automation/kubectl-ai-auto.sh --iterations 50 "diagnose and fix all issues in cluster"
```

### 5. Leverage MCP for Organization-Specific Needs

Create custom MCP servers for:
- Internal deployment workflows
- Compliance checks
- Custom monitoring integrations
- Organization-specific best practices

## Command-Line Options

### kubectl-ai-auto.sh Options

```
Usage:
    kubectl-ai-auto.sh [options] <query>
    kubectl-ai-auto.sh --batch <file>
    kubectl-ai-auto.sh --init
    kubectl-ai-auto.sh --help

Options:
    --init              Initialize automation configuration
    --batch <file>      Run queries from a batch file
    --iterations <n>    Set maximum iterations (default: 20)
    --verbose <level>   Set verbose level (0-2, default: 1)
    --help              Show this help message
```

### Environment Variables

```bash
# Override kubectl-ai binary location
export KUBECTL_AI_BIN=/custom/path/kubectl-ai

# Override config directory
export CONFIG_DIR=/custom/config/path

# Set MCP server environment variables
export MCP_TOKEN=your-token-here
export MY_API_KEY=your-api-key
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Configure kubectl
        run: |
          echo "${{ secrets.KUBECONFIG }}" > kubeconfig
          export KUBECONFIG=kubeconfig
      
      - name: Run kubectl-ai automation
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          ./automation/kubectl-ai-auto.sh --batch deployment-tasks.txt
```

### GitLab CI Example

```yaml
deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - ./automation/kubectl-ai-auto.sh --init
    - ./automation/kubectl-ai-auto.sh --batch deployment-tasks.txt
  only:
    - main
```

## Troubleshooting

### Common Issues

#### 1. kubectl-ai binary not found

```bash
# Build the binary
cd /path/to/kubectl-ai
make build

# Or specify custom path
export KUBECTL_AI_BIN=/path/to/kubectl-ai
```

#### 2. MCP servers not connecting

```bash
# Check MCP configuration
cat ~/.config/kubectl-ai/mcp.yaml

# Test MCP server manually
npx -y @modelcontextprotocol/server-sequential-thinking

# Check environment variables
echo $MCP_TOKEN
```

#### 3. Operations timing out

```bash
# Increase iteration limit
./automation/kubectl-ai-auto.sh --iterations 50 "your query"

# Increase verbose level to see what's happening
./automation/kubectl-ai-auto.sh --verbose 2 "your query"
```

#### 4. Permission denied errors

```bash
# Make scripts executable
chmod +x automation/kubectl-ai-auto.sh
chmod +x automation/cluster-deployment.sh

# Check kubectl access
kubectl auth can-i create deployment
```

### Debug Mode

Enable maximum verbosity:

```bash
./automation/kubectl-ai-auto.sh --verbose 2 "deploy app" 2>&1 | tee debug.log
```

Check kubectl-ai trace file:

```bash
tail -f /tmp/kubectl-ai-trace.txt
```

## Security Considerations

### 1. Credential Management

- Store sensitive credentials in environment variables
- Use Kubernetes secrets for in-cluster deployments
- Rotate API keys regularly

### 2. Permission Scope

- Use RBAC to limit kubectl-ai's permissions
- Test automation in non-production first
- Review generated kubectl commands in logs

### 3. Audit Logging

```bash
# Enable comprehensive logging
./automation/kubectl-ai-auto.sh --verbose 2 "deploy" 2>&1 | tee -a audit.log

# Review automation history
cat audit.log | grep -E "\[SUCCESS\]|\[ERROR\]"
```

## Advanced Usage

### Custom Automation Workflows

Create custom wrapper scripts:

```bash
#!/bin/bash
# custom-deploy.sh

ENVIRONMENT=$1
APP_VERSION=$2

# Initialize
./automation/kubectl-ai-auto.sh --init

# Switch to appropriate cluster
kubectl config use-context ${ENVIRONMENT}-cluster

# Deploy application
./automation/kubectl-ai-auto.sh "deploy myapp version ${APP_VERSION} with 3 replicas"

# Run smoke tests
./automation/kubectl-ai-auto.sh "verify myapp is responding to health checks"

# Monitor for 5 minutes
./automation/kubectl-ai-auto.sh "monitor myapp deployment and report any issues"
```

### Conditional Automation

```bash
#!/bin/bash
# conditional-deploy.sh

# Check cluster health first
if ./automation/kubectl-ai-auto.sh "check if cluster is healthy"; then
    echo "Cluster healthy, proceeding with deployment"
    ./automation/kubectl-ai-auto.sh --batch deployment-tasks.txt
else
    echo "Cluster unhealthy, aborting deployment"
    exit 1
fi
```

## Getting Help

- **Documentation**: See [README.md](../README.md) for main kubectl-ai documentation
- **MCP Details**: See [pkg/mcp/README.md](../pkg/mcp/README.md) for MCP integration
- **Issues**: Report issues at https://github.com/GoogleCloudPlatform/kubectl-ai/issues
- **Examples**: See `automation/examples/` for more examples

## Contributing

To contribute automation improvements:

1. Test thoroughly in safe environments
2. Document new features and examples
3. Follow existing code style
4. Submit pull requests with clear descriptions

---

**Note**: kubectl-ai automation mode is powerful. Always test in development environments before using in production. Review generated commands and maintain appropriate RBAC controls.
