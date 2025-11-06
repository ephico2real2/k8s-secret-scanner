# K8s Secret Scanner - Examples Reference

This document provides copy-paste ready commands for common use cases and scenarios.

## 📋 Quick Reference

### Basic Usage
```bash
# Show help with all examples
./search-secrets.sh --help

# Search single namespace
./search-secrets.sh -n default -s token

# Search for passwords in production namespace
./search-secrets.sh -n production -s password

# Search for default value 'ChangeMe' in default namespace
./search-secrets.sh -n default
```

### All Namespaces (with filtering)
```bash
# Search all namespaces (with default system skips)
./search-secrets.sh -A -s token

# Include system namespaces too
./search-secrets.sh -A -s token --include-system-namespaces

# Explicitly skip system namespaces
./search-secrets.sh -A -s password --skip-system-namespaces

# Use --all instead of -A
./search-secrets.sh --all -s token
```

### Custom Namespace Filtering
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

## 🎯 Use Case Examples

### Security Auditing
```bash
# Security audit: find passwords only in production
./search-secrets.sh -A -s password --only-namespaces="prod"

# Search for API keys excluding test environments
./search-secrets.sh -A -s "api" --skip-namespaces="test,dev"

# Comprehensive security scan including system namespaces
./search-secrets.sh -A -s "secret" --include-system-namespaces

# Find sensitive data patterns in user namespaces only
./search-secrets.sh -A -s "password\|secret\|key" --skip-system-namespaces
```

### Compliance & Configuration Management
```bash
# Compliance: find API configs in production only
./search-secrets.sh -A -s "api" --only-namespaces="prod,production"

# Find database connections, skip test environments
./search-secrets.sh -A -s "database" --skip-namespaces="test,dev"

# Locate certificates across all namespaces
./search-secrets.sh -A -s "ca.crt" --include-system-namespaces

# Find service configurations, skip monitoring noise
./search-secrets.sh -A -s service --skip-namespaces="monitoring"
```

### Troubleshooting & Operations
```bash
# Find debug configs in development environments
./search-secrets.sh -A -s debug --only-namespaces="dev,test"

# Search for specific service tokens
./search-secrets.sh -A -s "serviceaccount" --skip-system-namespaces

# Find configuration issues in application namespaces
./search-secrets.sh -A -s "config" --skip-namespaces="system,kube,openshift"

# Locate endpoint configurations
./search-secrets.sh -A -s "endpoint\|url\|host" --only-namespaces="prod"
```

### Advanced Combinations
```bash
# Config audit: find URLs everywhere including system
./search-secrets.sh -A -s http --include-system-namespaces

# Find tokens, skip default system patterns
./search-secrets.sh -A -s "token" --skip-namespaces="openshift,kube"

# Search for credentials in specific environments only
./search-secrets.sh -A -s "credential" --only-namespaces="staging,prod"

# Find certificates, exclude test and development
./search-secrets.sh -A -s "cert\|crt\|key" --skip-namespaces="test,dev,staging"
```

## 🔍 Search Pattern Examples

### What the Script Searches
The script searches in three locations:
1. **Secret Names** - The `metadata.name` field
2. **Data Key Names** - Keys in the `data` section  
3. **Data Values** - Base64-decoded values (text only)

### Search Pattern Examples
```bash
# Search in secret names (metadata.name)
./search-secrets.sh -n default -s token         # Finds secrets named *token*

# Search in data key names
./search-secrets.sh -n default -s namespace     # Finds keys named "namespace"
./search-secrets.sh -n default -s ca.crt        # Finds keys named "ca.crt"

# Search in data values (decoded content)  
./search-secrets.sh -n default -s default       # Finds "default" in decoded values
./search-secrets.sh -n default -s localhost     # Finds "localhost" in configurations
```

## 🚨 Security & Compliance Scenarios

### High-Security Environments
```bash
# Audit production secrets only (no system namespaces)
./search-secrets.sh -A -s "password\|secret\|key" --only-namespaces="prod" 

# Find API keys in production, exclude monitoring/logging
./search-secrets.sh -A -s "api" --only-namespaces="prod" --skip-namespaces="monitoring,logging"

# Comprehensive certificate audit including system
./search-secrets.sh -A -s "certificate\|cert\|ca\|tls" --include-system-namespaces
```

### Development & Testing
```bash
# Find test credentials that might be hardcoded
./search-secrets.sh -A -s "test\|demo\|sample" --only-namespaces="dev,test"

# Locate debug configurations
./search-secrets.sh -A -s "debug\|trace\|verbose" --only-namespaces="dev,test,staging"

# Find development database connections
./search-secrets.sh -A -s "localhost\|127.0.0.1\|dev" --only-namespaces="dev,test"
```

### Operations & Monitoring
```bash
# Find monitoring configurations (exclude system noise)
./search-secrets.sh -A -s "monitor\|metric\|alert" --skip-namespaces="kube,openshift"

# Locate logging configurations
./search-secrets.sh -A -s "log\|syslog\|elasticsearch" --skip-namespaces="kube-system"

# Find backup configurations
./search-secrets.sh -A -s "backup\|restore\|archive" --skip-system-namespaces
```

## 🧪 Testing Examples

### Edge Cases
```bash
# Test with non-existent namespace
./search-secrets.sh -n nonexistent-namespace -s token

# Test with empty search value
./search-secrets.sh -n default -s ""

# Test with special characters
./search-secrets.sh -n default -s "ca.crt"
./search-secrets.sh -n default -s "app-config"
```

### Performance Testing
```bash
# Efficient: target specific namespace
./search-secrets.sh -A -s token --only-namespaces="default"

# Test with unlikely search term
./search-secrets.sh -A -s rare-string-unlikely-to-exist

# Large search with filtering
./search-secrets.sh -A -s "config" --skip-namespaces="kube,openshift,monitoring"
```

## 📊 Output Examples

### Successful Search
```
=== SUMMARY ===
Total secrets checked: 15 across all namespaces  
Namespaces skipped: 12
Value 'token' found in 8 location(s):
  - Namespace: default, Secret: api-token, Location: secret name
  - Namespace: default, Secret: service-account, Key: token, Location: data key name
  - Namespace: prod, Secret: app-config, Key: api-token, Location: data value
```

### No Results Found
```
=== SUMMARY ===
Total secrets checked: 247 across all namespaces
Namespaces skipped: 15  
Value 'nonexistent' not found in any secrets across all namespaces
```

### Binary Data Handling
```
Checking namespace: production
  Found 10 secrets to check in namespace 'production'
    Checking secret: tls-certificate
    [SKIPPED] Key 'ca.crt' contains binary data
    [SKIPPED] Key 'tls.key' contains binary data
    [FOUND] in key name 'ca.crt'
```

---

For more detailed information, see the [Complete Usage Guide](USAGE.md).