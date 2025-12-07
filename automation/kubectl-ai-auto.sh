#!/bin/bash
# kubectl-ai Automation Script
# This script automates kubectl-ai operations with MCP client mode enabled
# and automatic confirmation for streamlined deployment workflows

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
KUBECTL_AI_BIN="${PROJECT_ROOT}/bin/kubectl-ai"
CONFIG_DIR="${HOME}/.config/kubectl-ai"
MCP_CONFIG="${CONFIG_DIR}/mcp.yaml"
AUTO_CONFIG="${CONFIG_DIR}/automation.yaml"
SKIP_PERMISSIONS=true
MAX_ITERATIONS=20
VERBOSE_LEVEL=1

# Function to print colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl-ai binary exists
    if [ ! -f "${KUBECTL_AI_BIN}" ]; then
        log_error "kubectl-ai binary not found at ${KUBECTL_AI_BIN}"
        log_info "Building kubectl-ai..."
        cd "${PROJECT_ROOT}" && make build
        if [ $? -eq 0 ]; then
            log_success "kubectl-ai built successfully"
        else
            log_error "Failed to build kubectl-ai"
            exit 1
        fi
    else
        log_success "kubectl-ai binary found"
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Function to initialize configuration
init_config() {
    log_info "Initializing automation configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "${CONFIG_DIR}"
    
    # Create automation config if it doesn't exist
    if [ ! -f "${AUTO_CONFIG}" ]; then
        cat > "${AUTO_CONFIG}" << 'EOF'
# kubectl-ai Automation Configuration
# This file configures automated behavior for kubectl-ai

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
EOF
        log_success "Created automation configuration at ${AUTO_CONFIG}"
    else
        log_info "Automation configuration already exists at ${AUTO_CONFIG}"
    fi
    
    # Ensure MCP config exists
    if [ ! -f "${MCP_CONFIG}" ]; then
        log_warning "MCP configuration not found, using default settings"
    else
        log_success "MCP configuration found at ${MCP_CONFIG}"
    fi
}

# Function to run kubectl-ai in automation mode
run_automated() {
    local query="$1"
    
    if [ -z "${query}" ]; then
        log_error "No query provided"
        echo "Usage: $0 <query>"
        exit 1
    fi
    
    log_info "Running kubectl-ai in automation mode..."
    log_info "Query: ${query}"
    
    # Build command with automation flags
    local cmd="${KUBECTL_AI_BIN}"
    cmd="${cmd} --mcp-client"
    cmd="${cmd} --skip-permissions"
    cmd="${cmd} --quiet"
    cmd="${cmd} --max-iterations ${MAX_ITERATIONS}"
    cmd="${cmd} --show-tool-output"
    cmd="${cmd} -v=${VERBOSE_LEVEL}"
    cmd="${cmd} \"${query}\""
    
    log_info "Executing command: ${cmd}"
    echo ""
    
    # Execute the command
    eval "${cmd}"
    
    if [ $? -eq 0 ]; then
        log_success "Automation completed successfully"
        return 0
    else
        log_error "Automation failed"
        return 1
    fi
}

# Function to run batch automation from file
run_batch() {
    local batch_file="$1"
    
    if [ ! -f "${batch_file}" ]; then
        log_error "Batch file not found: ${batch_file}"
        exit 1
    fi
    
    log_info "Running batch automation from ${batch_file}..."
    
    local line_num=0
    local success_count=0
    local fail_count=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_num++))
        
        # Skip empty lines and comments
        if [ -z "${line}" ] || [[ "${line}" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        log_info "Executing query ${line_num}: ${line}"
        
        if run_automated "${line}"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        
        echo ""
        echo "---"
        echo ""
    done < "${batch_file}"
    
    log_info "Batch automation complete"
    log_success "Successful queries: ${success_count}"
    if [ ${fail_count} -gt 0 ]; then
        log_error "Failed queries: ${fail_count}"
        return 1
    fi
    
    return 0
}

# Function to show usage
show_usage() {
    cat << EOF
kubectl-ai Automation Script

Usage:
    $0 [options] <query>
    $0 --batch <file>
    $0 --init
    $0 --help

Options:
    --init              Initialize automation configuration
    --batch <file>      Run queries from a batch file (one query per line)
    --iterations <n>    Set maximum iterations (default: 20)
    --verbose <level>   Set verbose level (0-2, default: 1)
    --help              Show this help message

Examples:
    # Initialize configuration
    $0 --init

    # Run a single automated query
    $0 "deploy nginx app in default namespace"

    # Run queries from a batch file
    $0 --batch deployment-tasks.txt

    # Run with custom iteration limit
    $0 --iterations 30 "scale all deployments in production namespace to 3 replicas"

Environment Variables:
    KUBECTL_AI_BIN      Path to kubectl-ai binary (default: ${PROJECT_ROOT}/bin/kubectl-ai)
    CONFIG_DIR          kubectl-ai configuration directory (default: ${HOME}/.config/kubectl-ai)

Configuration:
    Automation config:  ${AUTO_CONFIG}
    MCP config:         ${MCP_CONFIG}

EOF
}

# Main script logic
main() {
    # Parse command line arguments
    local batch_mode=false
    local batch_file=""
    local init_only=false
    
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --init)
                init_only=true
                shift
                ;;
            --batch)
                batch_mode=true
                batch_file="$2"
                shift 2
                ;;
            --iterations)
                MAX_ITERATIONS="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE_LEVEL="$2"
                shift 2
                ;;
            *)
                # Remaining arguments are the query
                break
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # Initialize configuration
    init_config
    
    if [ "${init_only}" = true ]; then
        log_success "Initialization complete"
        exit 0
    fi
    
    # Run automation
    if [ "${batch_mode}" = true ]; then
        run_batch "${batch_file}"
    else
        # Join all remaining arguments as the query
        local query="$*"
        run_automated "${query}"
    fi
}

# Execute main function
main "$@"
