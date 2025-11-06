#!/bin/bash

# Default values
NAMESPACE=""
SEARCH_VALUE="ChangeMe"
ALL_NAMESPACES=false
SKIP_NAMESPACES="openshift,kube,splunk,ocp"
ONLY_NAMESPACES=""
SKIP_SYSTEM_NAMESPACES=true

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [-n NAMESPACE | -A] [-s SEARCH_VALUE] [OPTIONS]"
    echo "  -n NAMESPACE              Kubernetes namespace to search (required unless -A is used)"
    echo "  -A, --all                 Search in all namespaces"
    echo "  -s SEARCH_VALUE           Optional: Value to search for (default: ChangeMe)"
    echo "  --skip-namespaces=PATTERNS Comma-separated patterns to skip (default: openshift,kube,splunk,ocp)"
    echo "  --only-namespaces=PATTERNS Only search namespaces matching these comma-separated patterns"
    echo "  --skip-system-namespaces  Skip system namespaces (default: enabled)"
    echo "  --include-system-namespaces Include system namespaces"
    echo "  -h                        Show this help message"
    echo ""
    echo "Examples:"
    echo ""
    echo "Basic Usage:"
    echo "  $0 -n default -s token                            # Search single namespace"
    echo "  $0 -n production -s password                     # Search for passwords in production namespace"
    echo "  $0 -n default                                    # Search for default value 'ChangeMe' in default namespace"
    echo ""
    echo "All Namespaces (with filtering):"
    echo "  $0 -A -s token                                    # Search all namespaces (with default system skips)"
    echo "  $0 -A -s token --include-system-namespaces        # Include system namespaces too"
    echo "  $0 -A -s password --skip-system-namespaces        # Explicitly skip system namespaces"
    echo ""
    echo "Custom Namespace Filtering:"
    echo "  $0 -A -s token --skip-namespaces=\"test,dev\"        # Skip namespaces containing 'test' or 'dev'"
    echo "  $0 -A -s token --skip-namespaces=\"kafka,monitoring\" # Skip specific application namespaces"
    echo "  $0 -A -s token --only-namespaces=\"prod,staging\"   # Only search namespaces containing 'prod' or 'staging'"
    echo "  $0 -s token --only-namespaces=\"default\"           # Search only default namespace (auto-enables -A)"
    echo ""
    echo "Advanced Combinations:"
    echo "  $0 -A -s password --only-namespaces=\"prod\"        # Security audit: find passwords only in production"
    echo "  $0 -A -s http --include-system-namespaces         # Config audit: find URLs everywhere including system"
    echo "  $0 -A -s debug --only-namespaces=\"dev,test\"       # Find debug configs in development environments"
    echo "  $0 -A -s service --skip-namespaces=\"monitoring\"   # Find service references, skip monitoring noise"
    echo "  $0 -A -s ca.crt --include-system-namespaces       # Find certificates across all namespaces"
    echo ""
    echo "Real-world Scenarios:"
    echo "  $0 -A -s \"api\" --only-namespaces=\"prod,production\" # Compliance: find API configs in production only"
    echo "  $0 -A -s \"database\" --skip-namespaces=\"test,dev\"   # Find database connections, skip test environments"
    echo "  $0 -A -s \"token\" --skip-namespaces=\"openshift,kube\" # Find tokens, skip default system patterns"
    exit 1
}

# Function to check if namespace should be skipped
should_skip_namespace() {
    local namespace="$1"
    
    # If only-namespaces is specified, check if namespace matches any pattern
    # This takes precedence over all other filtering
    if [ -n "$ONLY_NAMESPACES" ]; then
        local match_found=false
        IFS=',' read -ra PATTERNS <<< "$ONLY_NAMESPACES"
        for pattern in "${PATTERNS[@]}"; do
            pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Debug output
            # echo "[DEBUG] Checking namespace '$namespace' against pattern '$pattern'"
            if [[ "$namespace" == *"$pattern"* ]]; then
                match_found=true
                # echo "[DEBUG] MATCH FOUND for namespace '$namespace'"
                break
            fi
        done
        if [ "$match_found" = false ]; then
            # echo "[DEBUG] NO MATCH - skipping namespace '$namespace'"
            return 0  # Skip this namespace
        else
            # echo "[DEBUG] MATCH - processing namespace '$namespace'"
            return 1  # Don't skip - only-namespaces overrides all other filters
        fi
    fi
    
    # Check skip patterns
    if [ -n "$SKIP_NAMESPACES" ]; then
        IFS=',' read -ra PATTERNS <<< "$SKIP_NAMESPACES"
        for pattern in "${PATTERNS[@]}"; do
            pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ "$namespace" == *"$pattern"* ]]; then
                return 0  # Skip this namespace
            fi
        done
    fi
    
    # Check system namespaces if skip-system-namespaces is enabled
    if [ "$SKIP_SYSTEM_NAMESPACES" = true ]; then
        case "$namespace" in
            kube-*|openshift-*|ibm-*|calico-*|tigera-*|cert-manager*|ingress-*|monitoring-*|logging-*|default|kube*)
                return 0  # Skip system namespace
                ;;
        esac
    fi
    
    return 1  # Don't skip
}

# Parse command line arguments
while getopts "n:s:Ah-:" opt; do
    case $opt in
        n)
            NAMESPACE="$OPTARG"
            ;;
        s)
            SEARCH_VALUE="$OPTARG"
            ;;
        A)
            ALL_NAMESPACES=true
            ;;
        h)
            usage
            ;;
        -)
            case "$OPTARG" in
                all)
                    ALL_NAMESPACES=true
                    ;;
                help)
                    usage
                    ;;
                skip-namespaces=*)
                    SKIP_NAMESPACES="${OPTARG#skip-namespaces=}"
                    SKIP_SYSTEM_NAMESPACES=false  # Disable system namespace skipping when custom patterns are provided
                    ;;
                skip-namespaces)
                    if [ -n "$2" ] && [[ "$2" != -* ]]; then
                        SKIP_NAMESPACES="$2"
                        SKIP_SYSTEM_NAMESPACES=false
                        shift
                    else
                        echo "Option --skip-namespaces requires an argument." >&2
                        usage
                    fi
                    ;;
                only-namespaces=*)
                    ONLY_NAMESPACES="${OPTARG#only-namespaces=}"
                    SKIP_SYSTEM_NAMESPACES=false  # Disable system namespace skipping when only-namespaces is used
                    ;;
                only-namespaces)
                    if [ -n "$2" ] && [[ "$2" != -* ]]; then
                        ONLY_NAMESPACES="$2"
                        SKIP_SYSTEM_NAMESPACES=false
                        shift
                    else
                        echo "Option --only-namespaces requires an argument." >&2
                        usage
                    fi
                    ;;
                skip-system-namespaces)
                    SKIP_SYSTEM_NAMESPACES=true
                    ;;
                include-system-namespaces)
                    SKIP_SYSTEM_NAMESPACES=false
                    ;;
                *)
                    echo "Invalid long option: --$OPTARG" >&2
                    usage
                    ;;
            esac
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check if namespace is provided or all namespaces flag is set
# --only-namespaces automatically enables all namespaces mode
if [ -n "$ONLY_NAMESPACES" ]; then
    ALL_NAMESPACES=true
fi

# If single namespace is specified, disable system namespace filtering
if [ -n "$NAMESPACE" ]; then
    SKIP_SYSTEM_NAMESPACES=false
fi

if [ -z "$NAMESPACE" ] && [ "$ALL_NAMESPACES" = false ]; then
    echo -e "${RED}Error: Either -n NAMESPACE or -A (all namespaces) is required${NC}"
    usage
fi

if [ -n "$NAMESPACE" ] && [ "$ALL_NAMESPACES" = true ]; then
    echo -e "${RED}Error: Cannot use both -n and -A options together${NC}"
    usage
fi

# Get namespaces to search
if [ "$ALL_NAMESPACES" = true ]; then
    echo -e "${GREEN}Searching for value '$SEARCH_VALUE' in all secrets across all namespaces...${NC}"
    namespaces=$(oc get namespaces -o json 2>/dev/null | jq -r '.items[].metadata.name')
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to get namespaces. Make sure you are authenticated to your OpenShift cluster.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Searching for value '$SEARCH_VALUE' in all secrets in namespace '$NAMESPACE'...${NC}"
    namespaces="$NAMESPACE"
fi

# Array to store found secrets
declare -a found_secrets_names=()
declare -a found_secrets_keys=()
declare -a found_locations=()
declare -a found_namespaces=()
found_count=0
total_secrets_checked=0

# Process each namespace
namespaces_skipped=0
while IFS= read -r current_namespace; do
    if [ -z "$current_namespace" ]; then
        continue
    fi
    
    # Check if this namespace should be skipped
    if should_skip_namespace "$current_namespace"; then
        echo -e "${GRAY}Skipping namespace: $current_namespace${NC}"
        ((namespaces_skipped++))
        continue
    fi
    
    echo -e "${CYAN}Checking namespace: $current_namespace${NC}"
    
    # Get all secrets in the current namespace
    secrets_json=$(oc get secrets -n "$current_namespace" -o json 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${RED}  [ERROR] Failed to get secrets from namespace '$current_namespace'${NC}"
        continue
    fi
    
    # Check if any secrets exist in this namespace
    secret_count=$(echo "$secrets_json" | jq '.items | length')
    if [ "$secret_count" -eq 0 ]; then
        echo -e "${GRAY}  No secrets found in namespace '$current_namespace'${NC}"
        continue
    fi
    
    echo -e "${GRAY}  Found $secret_count secrets to check in namespace '$current_namespace'${NC}"
    ((total_secrets_checked += secret_count))
    
    # Process each secret in the current namespace
    for i in $(seq 0 $((secret_count - 1))); do
        secret_name=$(echo "$secrets_json" | jq -r ".items[$i].metadata.name")
        echo -e "${GRAY}    Checking secret: $secret_name${NC}"
        
        # Check in secret name (metadata.name)
        if echo "$secret_name" | grep -q "$SEARCH_VALUE"; then
            found_secrets_names[$found_count]="$secret_name"
            found_secrets_keys[$found_count]="N/A"
            found_locations[$found_count]="secret name"
            found_namespaces[$found_count]="$current_namespace"
            ((found_count++))
            echo -e "${GREEN}    [FOUND] in secret name${NC}"
        fi
        
        # Get the secret data
        secret_data=$(oc get secret "$secret_name" -n "$current_namespace" -o json 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}    [ERROR] Error reading secret '$secret_name'${NC}"
            continue
        fi
        
        # Check if secret has data
        has_data=$(echo "$secret_data" | jq -r '.data // empty')
        if [ -z "$has_data" ]; then
            continue
        fi
        
        # Get all keys in the secret data
        keys=$(echo "$secret_data" | jq -r '.data | keys[]')
        
        # Process each key
        while IFS= read -r key; do
            if [ -z "$key" ]; then
                continue
            fi
            
            # Check if the search value is in the key name itself
            if echo "$key" | grep -q "$SEARCH_VALUE"; then
                found_secrets_names[$found_count]="$secret_name"
                found_secrets_keys[$found_count]="$key"
                found_locations[$found_count]="data key name"
                found_namespaces[$found_count]="$current_namespace"
                ((found_count++))
                echo -e "${GREEN}    [FOUND] in key name '$key'${NC}"
            fi
            
            # Get base64 encoded value
            encoded_value=$(echo "$secret_data" | jq -r ".data[\"$key\"]")
            
            # Try to decode base64 value using a temp file to avoid bash warnings
            temp_file=$(mktemp)
            if echo "$encoded_value" | base64 -d > "$temp_file" 2>/dev/null; then
                # Check if the decoded content is likely binary (contains null bytes)
                if grep -q $'\0' "$temp_file" 2>/dev/null; then
                    echo -e "${GRAY}    [SKIPPED] Key '$key' contains binary data${NC}"
                    rm -f "$temp_file"
                    continue
                fi
                
                # Read the decoded content
                decoded_value=$(cat "$temp_file")
                rm -f "$temp_file"
            else
                echo -e "${YELLOW}    [WARNING] Could not decode key '$key' (invalid base64)${NC}"
                rm -f "$temp_file"
                continue
            fi
            
            # Check if decoded value is empty
            if [ -z "$decoded_value" ]; then
                continue
            fi
            
            # Check if the search value is in the decoded content
            if echo "$decoded_value" | grep -q "$SEARCH_VALUE"; then
                found_secrets_names[$found_count]="$secret_name"
                found_secrets_keys[$found_count]="$key"
                found_locations[$found_count]="data value"
                found_namespaces[$found_count]="$current_namespace"
                ((found_count++))
                echo -e "${GREEN}    [FOUND] in key '$key' value${NC}"
            fi
        done <<< "$keys"
    done
done <<< "$namespaces"

# Display summary
echo ""
echo -e "${MAGENTA}=== SUMMARY ===${NC}"
if [ "$ALL_NAMESPACES" = true ]; then
    echo -e "${CYAN}Total secrets checked: $total_secrets_checked across all namespaces${NC}"
    if [ $namespaces_skipped -gt 0 ]; then
        echo -e "${GRAY}Namespaces skipped: $namespaces_skipped${NC}"
    fi
fi
if [ $found_count -gt 0 ]; then
    echo -e "${GREEN}Value '$SEARCH_VALUE' found in $found_count location(s):${NC}"
    for i in $(seq 0 $((found_count - 1))); do
        if [ "${found_secrets_keys[$i]}" = "N/A" ]; then
            echo -e "${WHITE}  - Namespace: ${found_namespaces[$i]}, Secret: ${found_secrets_names[$i]}, Location: ${found_locations[$i]}${NC}"
        else
            echo -e "${WHITE}  - Namespace: ${found_namespaces[$i]}, Secret: ${found_secrets_names[$i]}, Key: ${found_secrets_keys[$i]}, Location: ${found_locations[$i]}${NC}"
        fi
    done
else
    if [ "$ALL_NAMESPACES" = true ]; then
        echo -e "${YELLOW}Value '$SEARCH_VALUE' not found in any secrets across all namespaces${NC}"
    else
        echo -e "${YELLOW}Value '$SEARCH_VALUE' not found in any secrets in namespace '$NAMESPACE'${NC}"
    fi
fi
