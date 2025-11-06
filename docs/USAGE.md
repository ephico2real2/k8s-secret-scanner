# Search Secrets Script - Usage Guide

## Overview
The `search-secrets.sh` script searches for text patterns in Kubernetes/OpenShift secrets across:
- Secret names (metadata.name)
- Secret data key names  
- Secret data values (base64 decoded)

## Basic Syntax
```bash
./search-secrets.sh [-n NAMESPACE | -A] [-s SEARCH_VALUE] [OPTIONS]
```

## Core Options

### Required (choose one)
- `-n NAMESPACE` - Search specific namespace
- `-A, --all` - Search all namespaces

### Optional
- `-s SEARCH_VALUE` - Text to search for (default: "ChangeMe")
- `-h` - Show help message

## Namespace Filtering Options

### System Namespace Control
- `--skip-system-namespaces` - Skip system namespaces (default: enabled)
- `--include-system-namespaces` - Include system namespaces

### Custom Filtering
- `--skip-namespaces "pattern1,pattern2"` - Skip namespaces containing these patterns
- `--only-namespaces "pattern1,pattern2"` - Only search namespaces containing these patterns

### Default Skip Patterns
When using `-A` without custom patterns, these are skipped by default:
- `openshift`, `kube`, `splunk`, `ocp`
- System namespaces: `kube-*`, `openshift-*`, `ibm-*`, `cert-manager*`, etc.

## Common Use Cases

### 1. Single Namespace Search
```bash
# Search for "token" in default namespace
./search-secrets.sh -n default -s token

# Search for passwords in production namespace
./search-secrets.sh -n production -s password

# Search for default value "ChangeMe" in default namespace
./search-secrets.sh -n default
```

### 2. All Namespaces (Basic)
```bash
# Search all namespaces (with default system skips)
./search-secrets.sh -A -s token

# Include system namespaces too
./search-secrets.sh -A -s token --include-system-namespaces

# Explicitly skip system namespaces
./search-secrets.sh -A -s password --skip-system-namespaces
```

### 3. Custom Namespace Filtering
```bash
# Skip namespaces containing 'test' or 'dev'
./search-secrets.sh -A -s token --skip-namespaces="test,dev"

# Skip specific application namespaces
./search-secrets.sh -A -s token --skip-namespaces="kafka,monitoring"

# Only search namespaces containing 'prod' or 'staging'
./search-secrets.sh -A -s token --only-namespaces="prod,staging"

# Search only default namespace (auto-enables -A)
./search-secrets.sh -s token --only-namespaces="default"
```

### 4. Advanced Combinations
```bash
# Security audit: find passwords only in production
./search-secrets.sh -A -s password --only-namespaces="prod"

# Config audit: find URLs everywhere including system
./search-secrets.sh -A -s http --include-system-namespaces

# Find debug configs in development environments
./search-secrets.sh -A -s debug --only-namespaces="dev,test"

# Find service references, skip monitoring noise
./search-secrets.sh -A -s service --skip-namespaces="monitoring"

# Find certificates across all namespaces
./search-secrets.sh -A -s ca.crt --include-system-namespaces
```

### 5. Real-world Scenarios
```bash
# Compliance: find API configs in production only
./search-secrets.sh -A -s "api" --only-namespaces="prod,production"

# Find database connections, skip test environments
./search-secrets.sh -A -s "database" --skip-namespaces="test,dev"

# Find tokens, skip default system patterns
./search-secrets.sh -A -s "token" --skip-namespaces="openshift,kube"
```

## Search Locations

The script searches in three locations for each secret:

1. **Secret Names** - The `metadata.name` field
2. **Data Key Names** - Keys in the `data` section (e.g., "token", "password", "ca.crt")
3. **Data Values** - Base64-decoded values of the data keys

## Output Format

### During Search
```
Checking namespace: production
  Found 15 secrets to check in namespace 'production'
    Checking secret: api-credentials
    [FOUND] in key name 'api-key'
    [FOUND] in key 'password' value
```

### Summary
```
=== SUMMARY ===
Total secrets checked: 247 across all namespaces
Namespaces skipped: 12
Value 'password' found in 8 location(s):
  - Namespace: production, Secret: api-credentials, Key: password, Location: data value
  - Namespace: staging, Secret: db-secret, Location: secret name
```

## Performance Tips

### Efficient Searching
```bash
# Target specific namespaces instead of all
./search-secrets.sh -A -s token --only-namespaces "myapp"

# Use specific patterns to reduce scope
./search-secrets.sh -A -s password --skip-namespaces "system,monitoring,logging"
```

### Large Clusters
```bash
# Skip system namespaces to reduce load
./search-secrets.sh -A -s sensitive-data --skip-system-namespaces

# Focus on user applications only
./search-secrets.sh -A -s config --skip-namespaces "openshift,kube,ibm,cert-manager"
```

## Error Handling

### Common Issues
- `Error: Either -n NAMESPACE or -A (all namespaces) is required`
  - Solution: Specify either `-n namespace` or `-A`

- `Error: Cannot use both -n and -A options together`  
  - Solution: Choose either single namespace or all namespaces

- `[ERROR] Failed to get secrets from namespace 'xyz'`
  - Solution: Check namespace exists and you have access permissions

- `[WARNING] Could not decode key 'abc' (may not be text data)`
  - Normal: Some secrets contain binary data that can't be decoded

## Examples by Scenario

### Development
```bash
# Find debug configurations
./search-secrets.sh -A -s debug --only-namespaces "dev,test"

# Look for development passwords
./search-secrets.sh -A -s password --only-namespaces "dev"
```

### Production
```bash
# Security scan in production
./search-secrets.sh -A -s "password\|secret\|key" --only-namespaces "prod,production"

# Find external service configs
./search-secrets.sh -A -s "endpoint\|url\|host" --only-namespaces "prod"
```

### Operations
```bash
# Find certificates expiring soon (if stored as text)
./search-secrets.sh -A -s "2024" --include-system-namespaces

# Look for specific service accounts
./search-secrets.sh -A -s "serviceaccount" --skip-system-namespaces
```

## Test Suite

Run the comprehensive test suite to see all features:
```bash
./test-search-secrets.sh
```

This will demonstrate all supported scenarios with real examples from your cluster.