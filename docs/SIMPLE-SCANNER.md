# Simple K8s Secrets Scanner

🚀 **Ultra-simple "run and done" secret scanner for Kubernetes clusters**

Perfect for quick security audits, compliance checks, and finding sensitive data without complex configuration.

## ✨ Why Use the Simple Scanner?

- **No flags to remember** - Just search terms and optional namespace patterns
- **Auto-excludes system namespaces** - Focuses on user applications
- **Instant results** - Fast one-pipeline processing
- **Smart output limiting** - Shows max 20 results to avoid spam
- **Zero configuration** - Works out of the box

## 🚀 Quick Start

```bash
# Basic searches - just run and done!
./simple-k8s-secrets-scanner.sh password    # Find passwords
./simple-k8s-secrets-scanner.sh token       # Find tokens  
./simple-k8s-secrets-scanner.sh api         # Find API configs
./simple-k8s-secrets-scanner.sh             # Find default "ChangeMe" values
```

## 📋 Usage

### Basic Syntax
```bash
./simple-k8s-secrets-scanner.sh [SEARCH_TERM] [NAMESPACE_PATTERN]
```

### Parameters
- **`SEARCH_TERM`** (optional) - Text to search for (default: "ChangeMe")
- **`NAMESPACE_PATTERN`** (optional) - Regex pattern to filter namespaces (default: search all)

## 🎯 Examples

### Security & Compliance
```bash
# Find passwords across all user namespaces
./simple-k8s-secrets-scanner.sh password

# Find API keys and tokens
./simple-k8s-secrets-scanner.sh api
./simple-k8s-secrets-scanner.sh token

# Find database connections
./simple-k8s-secrets-scanner.sh database
./simple-k8s-secrets-scanner.sh postgres

# Find certificates
./simple-k8s-secrets-scanner.sh cert
./simple-k8s-secrets-scanner.sh ca.crt
```

### Environment-Specific Searches
```bash
# Search only production namespaces
./simple-k8s-secrets-scanner.sh password prod

# Search development environments
./simple-k8s-secrets-scanner.sh debug dev

# Search staging environments  
./simple-k8s-secrets-scanner.sh config staging

# Search specific application namespaces
./simple-k8s-secrets-scanner.sh token kafka
./simple-k8s-secrets-scanner.sh secret myapp
```

### Default Value Audits
```bash
# Find default "ChangeMe" values (security risk)
./simple-k8s-secrets-scanner.sh

# Find common weak passwords
./simple-k8s-secrets-scanner.sh admin
./simple-k8s-secrets-scanner.sh test
./simple-k8s-secrets-scanner.sh demo
```

## 🔍 What It Searches

The scanner looks for your search term in **three locations**:

1. **Secret Names** - The name of the secret itself
2. **Data Key Names** - Keys within the secret data (e.g., "token", "password", "ca.crt")  
3. **Data Values** - The actual decoded content of secret values

## 📊 Output Format

```
🔍 Scanning for: 'password'
📂 Namespaces: prod         # (only shown if namespace filter used)

✅ myapp-prod/database-credentials (name)
✅ myapp-prod/api-config (key:admin_password)  
✅ myapp-prod/app-secrets (value:db_config)

✅ Found 12 matches
📄 (showing first 20 results)    # (only shown if >20 results)
💡 Inspect: kubectl get secret <name> -n <namespace> -o yaml
```

### Output Indicators
- **`(name)`** - Found in secret name
- **`(key:keyname)`** - Found in data key name
- **`(value:keyname)`** - Found in decoded data value

## 🛡️ System Namespace Filtering

**Automatically excluded namespaces:**
- `kube-*` (Kubernetes system)
- `openshift-*` (OpenShift system)  
- `default` (Default namespace)
- `cert-manager*` (Certificate management)
- `ibm-*` (IBM system namespaces)
- `calico-*`, `tigera-*` (Network policy)
- `ingress-*` (Ingress controllers)
- `monitoring-*`, `logging-*` (Observability)

This focuses your search on **user applications** where sensitive data is more likely to be found.

## ⚡ Performance Features

- **Smart limiting**: Shows max 20 results to prevent spam
- **Single pipeline**: All processing in one kubectl + jq command
- **Case-insensitive**: Finds matches regardless of case
- **Binary data safe**: Handles base64 decoding errors gracefully
- **Fast exit**: Stops processing if no namespaces match filter

## 🧪 Real-World Examples

### Security Audit Scenarios
```bash
# Comprehensive password audit
./simple-k8s-secrets-scanner.sh password

# Find hardcoded credentials  
./simple-k8s-secrets-scanner.sh admin
./simple-k8s-secrets-scanner.sh root

# API security check
./simple-k8s-secrets-scanner.sh apikey
./simple-k8s-secrets-scanner.sh secret
```

### Compliance Checks
```bash
# Production-only compliance scan
./simple-k8s-secrets-scanner.sh password prod
./simple-k8s-secrets-scanner.sh key production

# Find certificates for renewal tracking
./simple-k8s-secrets-scanner.sh cert
./simple-k8s-secrets-scanner.sh ca.crt
./simple-k8s-secrets-scanner.sh tls
```

### Configuration Management
```bash
# Find database configurations
./simple-k8s-secrets-scanner.sh database
./simple-k8s-secrets-scanner.sh postgres
./simple-k8s-secrets-scanner.sh mysql

# Locate service endpoints
./simple-k8s-secrets-scanner.sh endpoint
./simple-k8s-secrets-scanner.sh url
./simple-k8s-secrets-scanner.sh host
```

## 🆘 Troubleshooting

### No Results Found
```
❌ No matches found for 'searchterm'
💡 Try without namespace filter: ./simple-k8s-secrets-scanner.sh searchterm
```

**Solutions:**
- Check spelling of search term
- Try broader search terms (e.g., "pass" instead of "password")
- Remove namespace filter to search all namespaces
- Verify cluster connection: `kubectl get namespaces`

### Too Many Results
```
✅ Found 157 matches
📄 (showing first 20 results)
```

**Solutions:**
- Add namespace filter: `./simple-k8s-secrets-scanner.sh token prod`
- Use more specific search terms
- Use the full `search-secrets.sh` for advanced filtering

### Permission Errors
**Solutions:**
- Verify cluster access: `kubectl auth can-i list secrets --all-namespaces`
- Check RBAC permissions for secret access
- Ensure kubeconfig is properly configured

## 🔄 Comparison with Full Scanner

| Feature | Simple Scanner | Full Scanner (`search-secrets.sh`) |
|---------|---------------|-----------------------------------|
| **Usage** | 2 arguments max | 10+ flags and options |
| **Lines of Code** | ~40 lines | ~300+ lines |  
| **Learning Curve** | Instant | Requires reading docs |
| **Namespace Control** | Auto + regex pattern | Advanced skip/only patterns |
| **Output Control** | Smart defaults | Comprehensive reporting |
| **Use Case** | Quick audits | Enterprise workflows |

## 🚀 Next Steps

After finding secrets with the simple scanner:

1. **Inspect secrets**: `kubectl get secret <name> -n <namespace> -o yaml`
2. **Detailed analysis**: Use `search-secrets.sh` for advanced filtering
3. **Security action**: Rotate found credentials, fix weak passwords
4. **Compliance**: Document findings for security audits

---

For advanced features and enterprise use cases, see the [Full Scanner Documentation](USAGE.md).