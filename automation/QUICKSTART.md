# kubectl-ai Automation Quick Reference

## One-Line Commands

### Basic Automation
```bash
# Single automated command with auto-approve
kubectl-ai --skip-permissions --mcp-client --quiet "your command here"

# Using the automation wrapper
./automation/kubectl-ai-auto.sh "your command here"
```

### Common Operations

#### Deployments
```bash
# Deploy application
./automation/kubectl-ai-auto.sh "deploy nginx with 3 replicas in production"

# Scale deployment
./automation/kubectl-ai-auto.sh "scale nginx to 5 replicas"

# Update image
./automation/kubectl-ai-auto.sh "update nginx deployment to use nginx:1.21 image"
```

#### Cluster Management
```bash
# Check cluster health
./automation/kubectl-ai-auto.sh "check health of all nodes and report issues"

# List resources
./automation/kubectl-ai-auto.sh "list all deployments across all namespaces"

# Cleanup
./automation/kubectl-ai-auto.sh "delete all pods with status Failed in default namespace"
```

#### Troubleshooting
```bash
# Diagnose issues
./automation/kubectl-ai-auto.sh --iterations 30 "find and fix all crashlooping pods"

# Check logs
./automation/kubectl-ai-auto.sh "show me logs from nginx pods in last 5 minutes"

# Debug service
./automation/kubectl-ai-auto.sh "diagnose why my-service is not responding"
```

### Batch Processing

Create a file `tasks.txt`:
```text
create namespace demo if not exists
deploy redis in demo namespace
deploy app with 3 replicas in demo namespace
create ingress for app in demo namespace
```

Run batch:
```bash
./automation/kubectl-ai-auto.sh --batch tasks.txt
```

### Multi-Cluster

```bash
# Single cluster
kubectl config use-context dev-cluster
./automation/kubectl-ai-auto.sh "deploy app in dev"

# Multiple clusters (edit cluster-deployment.sh first)
./automation/cluster-deployment.sh
```

## Configuration

### Initialize
```bash
./automation/kubectl-ai-auto.sh --init
```

This creates:
- `~/.config/kubectl-ai/automation.yaml` - Automation settings
- `~/.config/kubectl-ai/mcp.yaml` - MCP server configuration (if not exists)

### Edit Configuration
```bash
# Automation settings
vi ~/.config/kubectl-ai/automation.yaml

# MCP servers
vi ~/.config/kubectl-ai/mcp.yaml
```

## MCP Integration

### Default MCP Server
The automation automatically uses the sequential-thinking MCP server for enhanced reasoning.

### Add Custom MCP Server
Edit `~/.config/kubectl-ai/mcp.yaml`:

```yaml
servers:
  - name: sequential-thinking
    command: npx
    args:
      - -y
      - "@modelcontextprotocol/server-sequential-thinking"
  
  # Your custom server
  - name: my-tools
    command: /path/to/mcp-server
    env:
      API_KEY: "${MY_API_KEY}"
```

## Options Reference

### kubectl-ai-auto.sh

| Option | Description | Example |
|--------|-------------|---------|
| `--init` | Initialize configuration | `./kubectl-ai-auto.sh --init` |
| `--batch <file>` | Run from file | `./kubectl-ai-auto.sh --batch tasks.txt` |
| `--iterations <n>` | Set max iterations | `./kubectl-ai-auto.sh --iterations 30 "query"` |
| `--verbose <level>` | Logging (0-2) | `./kubectl-ai-auto.sh --verbose 2 "query"` |
| `--help` | Show help | `./kubectl-ai-auto.sh --help` |

### kubectl-ai Native Flags

| Flag | Description |
|------|-------------|
| `--skip-permissions` | Auto-approve all operations |
| `--mcp-client` | Enable MCP client mode |
| `--quiet` | Non-interactive mode |
| `--max-iterations <n>` | Maximum iterations (default: 20) |
| `--show-tool-output` | Display command output |
| `-v=<level>` | Verbose logging |

## Examples Directory

See `automation/examples/` for:
- `deployment-tasks.txt` - Sample deployment tasks
- `cluster-automation.txt` - Cluster management tasks
- `complete-workflow.sh` - Full automation workflow
- `mcp-config-example.yaml` - MCP configuration examples

## Troubleshooting

### Binary Not Found
```bash
cd /path/to/kubectl-ai
make build
```

### MCP Not Working
```bash
# Check MCP config
cat ~/.config/kubectl-ai/mcp.yaml

# Test MCP server manually
npx -y @modelcontextprotocol/server-sequential-thinking
```

### Verbose Debugging
```bash
./automation/kubectl-ai-auto.sh --verbose 2 "your query" 2>&1 | tee debug.log
```

### Check Logs
```bash
# kubectl-ai trace
tail -f /tmp/kubectl-ai-trace.txt

# Automation output
./automation/kubectl-ai-auto.sh "query" 2>&1 | tee automation.log
```

## Environment Variables

```bash
# Override binary location
export KUBECTL_AI_BIN=/custom/path/kubectl-ai

# Override config directory
export CONFIG_DIR=/custom/config

# MCP server tokens
export MCP_TOKEN=your-token
export CUSTOM_API_KEY=your-key
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run kubectl-ai automation
  env:
    GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
  run: ./automation/kubectl-ai-auto.sh --batch deploy.txt
```

### GitLab CI
```yaml
deploy:
  script:
    - ./automation/kubectl-ai-auto.sh --init
    - ./automation/kubectl-ai-auto.sh --batch deploy.txt
```

## Safety Tips

✅ **DO:**
- Test in dev/staging first
- Use descriptive queries
- Review logs regularly
- Set appropriate iteration limits
- Use RBAC to limit permissions

❌ **DON'T:**
- Run untested automation in production
- Use vague queries
- Ignore error messages
- Set excessive iteration limits without reason
- Grant unlimited permissions

## Quick Links

- [Full Automation Documentation](README.md)
- [Main kubectl-ai README](../README.md)
- [MCP Documentation](../pkg/mcp/README.md)
- [Tools Documentation](../docs/tools.md)

## Getting Help

```bash
# Automation script help
./automation/kubectl-ai-auto.sh --help

# kubectl-ai help
kubectl-ai --help

# View examples
ls -la automation/examples/
```

---

**Quick Tip**: Start with `./automation/kubectl-ai-auto.sh --init` then run `./automation/examples/complete-workflow.sh` to see automation in action!
