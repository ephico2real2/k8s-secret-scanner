#!/bin/bash

# Test script for search-secrets.sh - All supported scenarios
# This script demonstrates all the features and use cases

SCRIPT_PATH="./search-secrets.sh"
TEST_SEARCH_VALUE="token"  # Common value that should exist in most clusters

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${MAGENTA}=== SEARCH-SECRETS.SH TEST SUITE ===${NC}"
echo -e "${CYAN}Testing all supported scenarios and use cases${NC}"
echo ""

# Function to run test and show command
run_test() {
    local test_name="$1"
    local command="$2"
    local description="$3"
    
    echo -e "${BLUE}TEST: $test_name${NC}"
    echo -e "${WHITE}Command: $command${NC}"
    echo -e "${YELLOW}Description: $description${NC}"
    echo -e "${CYAN}Output:${NC}"
    echo "----------------------------------------"
    
    # Run the command and capture first 20 lines for demo
    eval "$command" 2>&1 | head -20
    
    echo "----------------------------------------"
    echo ""
    sleep 1
}

echo -e "${GREEN}1. BASIC USAGE TESTS${NC}"
echo ""

run_test "Help Display" \
    "$SCRIPT_PATH -h" \
    "Show help message with all options"

run_test "Single Namespace Search" \
    "$SCRIPT_PATH -n default -s '$TEST_SEARCH_VALUE'" \
    "Search for '$TEST_SEARCH_VALUE' in 'default' namespace only"

run_test "Default Search Value" \
    "$SCRIPT_PATH -n default" \
    "Search for default value 'ChangeMe' in 'default' namespace"

echo -e "${GREEN}2. ALL NAMESPACES TESTS${NC}"
echo ""

run_test "All Namespaces (Default Filtering)" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE'" \
    "Search all namespaces with default system namespace filtering"

run_test "All Namespaces (Include System)" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --include-system-namespaces" \
    "Search all namespaces including system namespaces"

run_test "All Namespaces (Long Form)" \
    "$SCRIPT_PATH --all -s '$TEST_SEARCH_VALUE'" \
    "Use --all instead of -A for all namespaces"

echo -e "${GREEN}3. NAMESPACE FILTERING TESTS${NC}"
echo ""

run_test "Custom Skip Patterns" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --skip-namespaces 'kafka,monitoring'" \
    "Skip namespaces containing 'kafka' or 'monitoring'"

run_test "Only Specific Patterns" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --only-namespaces 'default,test'" \
    "Only search namespaces containing 'default' or 'test'"

run_test "Explicit System Namespace Skipping" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --skip-system-namespaces" \
    "Explicitly enable system namespace skipping (default behavior)"

echo -e "${GREEN}4. SEARCH LOCATION TESTS${NC}"
echo ""

run_test "Search in Secret Names" \
    "$SCRIPT_PATH -n default -s 'token'" \
    "Find 'token' in secret names (metadata.name)"

run_test "Search in Data Key Names" \
    "$SCRIPT_PATH -n default -s 'namespace'" \
    "Find 'namespace' in data key names"

run_test "Search in Data Values" \
    "$SCRIPT_PATH -n default -s 'default'" \
    "Find 'default' in decoded data values"

echo -e "${GREEN}5. ADVANCED FILTERING COMBINATIONS${NC}"
echo ""

run_test "Multiple Skip Patterns" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --skip-namespaces 'openshift,kube,ibm,cert-manager'" \
    "Skip multiple system-related namespace patterns"

run_test "Production-Only Search" \
    "$SCRIPT_PATH -A -s 'password' --only-namespaces 'prod'" \
    "Search only production namespaces for sensitive data"

run_test "Development Environment Search" \
    "$SCRIPT_PATH -A -s 'debug' --only-namespaces 'dev,test,staging'" \
    "Search only development-related namespaces"

echo -e "${GREEN}6. REAL-WORLD SCENARIOS${NC}"
echo ""

run_test "Security Audit - Find Passwords" \
    "$SCRIPT_PATH -A -s 'password' --skip-system-namespaces" \
    "Security audit: Find 'password' across user namespaces"

run_test "Configuration Audit - Find URLs" \
    "$SCRIPT_PATH -A -s 'http' --include-system-namespaces" \
    "Find HTTP URLs in all secrets including system ones"

run_test "Compliance Check - Find API Keys" \
    "$SCRIPT_PATH -A -s 'key' --only-namespaces 'prod,production'" \
    "Compliance check: Find API keys only in production"

run_test "Troubleshooting - Find Service Names" \
    "$SCRIPT_PATH -A -s 'service' --skip-namespaces 'monitoring,logging'" \
    "Troubleshooting: Find service references, skip monitoring"

echo -e "${GREEN}7. EDGE CASES AND ERROR HANDLING${NC}"
echo ""

run_test "Invalid Namespace" \
    "$SCRIPT_PATH -n nonexistent-namespace -s '$TEST_SEARCH_VALUE'" \
    "Test behavior with non-existent namespace"

run_test "Empty Search Value" \
    "$SCRIPT_PATH -n default -s ''" \
    "Test with empty search value"

run_test "Special Characters Search" \
    "$SCRIPT_PATH -n default -s 'ca.crt'" \
    "Search for strings with special characters"

echo -e "${GREEN}8. PERFORMANCE AND EFFICIENCY TESTS${NC}"
echo ""

run_test "Targeted Namespace List" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' --only-namespaces 'default'" \
    "Efficient search: Target specific namespace via only-namespaces"

run_test "Minimal System Overhead" \
    "$SCRIPT_PATH -A -s 'rare-string-unlikely-to-exist'" \
    "Test with unlikely search term to see filtering in action"

echo -e "${GREEN}9. COMPREHENSIVE REPORTING${NC}"
echo ""

run_test "Full Report with Counts" \
    "$SCRIPT_PATH -A -s '$TEST_SEARCH_VALUE' | tail -10" \
    "Show summary section with namespace counts and statistics"

echo -e "${MAGENTA}=== TEST COMMANDS REFERENCE ===${NC}"
echo ""
echo -e "${WHITE}Copy and run these commands individually for testing:${NC}"
echo ""

cat << 'EOF'
# Basic Usage
./search-secrets.sh -h
./search-secrets.sh -n default -s token                            # Search single namespace
./search-secrets.sh -n production -s password                     # Search for passwords in production namespace
./search-secrets.sh -n default                                    # Search for default value 'ChangeMe' in default namespace

# All Namespaces (with filtering)
./search-secrets.sh -A -s token                                    # Search all namespaces (with default system skips)
./search-secrets.sh -A -s token --include-system-namespaces        # Include system namespaces too
./search-secrets.sh -A -s password --skip-system-namespaces        # Explicitly skip system namespaces
./search-secrets.sh --all -s token                                # Use --all instead of -A

# Custom Namespace Filtering
./search-secrets.sh -A -s token --skip-namespaces="test,dev"        # Skip namespaces containing 'test' or 'dev'
./search-secrets.sh -A -s token --skip-namespaces="kafka,monitoring" # Skip specific application namespaces
./search-secrets.sh -A -s token --only-namespaces="prod,staging"   # Only search namespaces containing 'prod' or 'staging'
./search-secrets.sh -s token --only-namespaces="default"           # Search only default namespace (auto-enables -A)

# Search Locations (what the script searches)
./search-secrets.sh -n default -s token         # In secret names
./search-secrets.sh -n default -s namespace     # In data key names  
./search-secrets.sh -n default -s default       # In data values

# Advanced Combinations
./search-secrets.sh -A -s password --only-namespaces="prod"        # Security audit: find passwords only in production
./search-secrets.sh -A -s http --include-system-namespaces         # Config audit: find URLs everywhere including system
./search-secrets.sh -A -s debug --only-namespaces="dev,test"       # Find debug configs in development environments
./search-secrets.sh -A -s service --skip-namespaces="monitoring"   # Find service references, skip monitoring noise
./search-secrets.sh -A -s ca.crt --include-system-namespaces       # Find certificates across all namespaces

# Real-world Scenarios
./search-secrets.sh -A -s "api" --only-namespaces="prod,production" # Compliance: find API configs in production only
./search-secrets.sh -A -s "database" --skip-namespaces="test,dev"   # Find database connections, skip test environments
./search-secrets.sh -A -s "token" --skip-namespaces="openshift,kube" # Find tokens, skip default system patterns

# Edge Cases and Error Handling
./search-secrets.sh -n nonexistent-namespace -s token             # Test with non-existent namespace
./search-secrets.sh -n default -s ""                              # Test with empty search value
./search-secrets.sh -n default -s "ca.crt"                        # Test with special characters

# Performance and Efficiency
./search-secrets.sh -A -s token --only-namespaces="default"        # Efficient: target specific namespace
./search-secrets.sh -A -s rare-string-unlikely-to-exist           # Test with unlikely search term
EOF

echo ""
echo -e "${GREEN}Test suite completed!${NC}"
echo -e "${CYAN}Use the reference commands above to test specific scenarios.${NC}"