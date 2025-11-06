# K8s Secret Scanner

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)]()

A powerful command-line tool for searching text patterns across Kubernetes and OpenShift secrets. Designed for security auditing, compliance checks, configuration management, and troubleshooting.

## 📚 Quick Navigation

- **[🚀 Simple Scanner Guide](docs/SIMPLE-SCANNER.md)** - Ultra-simple "run and done" scanner documentation
- **[📖 Complete Usage Guide](docs/USAGE.md)** - Comprehensive documentation with detailed examples
- **[📋 Examples Reference](docs/EXAMPLES.md)** - Copy-paste ready commands for common scenarios
- **[🚀 Quick Start](#-quick-start)** - Get started in 30 seconds
- **[🛠️ Installation](#️-installation)** - Setup instructions
- **[🎯 Common Use Cases](#-common-use-cases)** - Real-world examples

## ✨ Features

- 🚀 **Two Usage Modes**: Simple `simple-k8s-secrets-scanner.sh` for quick searches, full `search-secrets.sh` for enterprise use
- 🔍 **Multi-location Search**: Searches in secret names, data key names, and decoded data values
- 🏢 **Namespace Filtering**: Advanced filtering with skip patterns, only patterns, and system namespace control
- 🛑️ **Security Focused**: Built for security audits, compliance checks, and sensitive data discovery
- 🚀 **Performance Optimized**: Efficient filtering to reduce noise and focus searches
- 🎯 **Binary Data Handling**: Intelligently skips binary content while processing text data
- 📊 **Comprehensive Reporting**: Detailed summaries with location tracking and statistics

## 🚀 Quick Start

```bash
# 🚀 SIMPLE: Just run and done
./simple-k8s-secrets-scanner.sh password         # Find passwords 
./simple-k8s-secrets-scanner.sh token            # Find tokens
./simple-k8s-secrets-scanner.sh api prod         # Find "api" in prod namespaces only

# 🏢 ADVANCED: Full control (enterprise features)
./search-secrets.sh -n default -s token
./search-secrets.sh -A -s password --only-namespaces="prod,staging" 
./search-secrets.sh -A -s ca.crt --include-system-namespaces
```

## 📋 Prerequisites

- Kubernetes or OpenShift cluster access
- `oc` (OpenShift CLI) or `kubectl` installed and configured
- `jq` command-line JSON processor
- `bash` shell environment

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/ephico2real2/k8s-secret-scanner.git
cd k8s-secret-scanner

# Make the script executable
chmod +x search-secrets.sh

# Optional: Add to PATH for global access
sudo ln -s $(pwd)/search-secrets.sh /usr/local/bin/k8s-secret-scanner
```

## 📚 Usage

### Basic Syntax
```bash
./search-secrets.sh [-n NAMESPACE | -A] [-s SEARCH_VALUE] [OPTIONS]
```

### Core Options
- `-n NAMESPACE` - Search specific namespace
- `-A, --all` - Search all namespaces
- `-s SEARCH_VALUE` - Text pattern to search for (default: "ChangeMe")
- `--help` - Show comprehensive help with examples

### Advanced Filtering
- `--skip-namespaces=PATTERNS` - Skip namespaces containing these patterns
- `--only-namespaces=PATTERNS` - Only search namespaces containing these patterns
- `--include-system-namespaces` - Include system namespaces in search
- `--skip-system-namespaces` - Skip system namespaces (default)

## 🎯 Common Use Cases

### Security Auditing
```bash
# Find passwords in production namespaces only
./search-secrets.sh -A -s password --only-namespaces="prod"

# Search for API keys excluding test environments
./search-secrets.sh -A -s "api" --skip-namespaces="test,dev"

# Comprehensive security scan including system namespaces
./search-secrets.sh -A -s "secret" --include-system-namespaces
```

### Compliance & Configuration Management
```bash
# Find database connections, skip test environments
./search-secrets.sh -A -s "database" --skip-namespaces="test,dev"

# Locate certificates across all namespaces
./search-secrets.sh -A -s "ca.crt" --include-system-namespaces

# Find service configurations, skip monitoring noise
./search-secrets.sh -A -s service --skip-namespaces="monitoring"
```

### Troubleshooting
```bash
# Find debug configurations in development environments
./search-secrets.sh -A -s debug --only-namespaces="dev,test"

# Search for specific service tokens
./search-secrets.sh -A -s "serviceaccount" --skip-system-namespaces
```

## 📖 Documentation

For detailed information:
- **[Simple Scanner Guide](docs/SIMPLE-SCANNER.md)** - Ultra-simple "run and done" scanner with examples
- **[Complete Usage Guide](docs/USAGE.md)** - In-depth documentation with performance tips and error handling
- **[Examples Reference](docs/EXAMPLES.md)** - Extended examples for security, compliance, and troubleshooting scenarios

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Execute all test scenarios
./test-search-secrets.sh

# Or test individual scenarios manually
./search-secrets.sh --help  # See all examples
```

## 🔧 What It Searches

The tool searches in three locations for each secret:

1. **Secret Names** (`metadata.name`) - The name of the secret itself
2. **Data Key Names** - Keys in the secret's data section (e.g., "token", "password", "ca.crt")
3. **Data Values** - Base64-decoded content of secret values (text data only)

## 📊 Output Format

```
Searching for value 'token' in all secrets across all namespaces...
Checking namespace: production
  Found 15 secrets to check in namespace 'production'
    Checking secret: api-credentials
    [FOUND] in secret name
    [FOUND] in key name 'api-token'
    [SKIPPED] Key 'certificate' contains binary data

=== SUMMARY ===
Total secrets checked: 247 across all namespaces
Namespaces skipped: 12
Value 'token' found in 8 location(s):
  - Namespace: production, Secret: api-credentials, Location: secret name
  - Namespace: production, Secret: api-credentials, Key: api-token, Location: data key name
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
```bash
# Clone and setup
git clone https://github.com/ephico2real2/k8s-secret-scanner.git
cd k8s-secret-scanner

# Run tests
./test-search-secrets.sh

# Test specific functionality
./search-secrets.sh -n default -s test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 Check the [Usage Guide](docs/USAGE.md) for detailed examples
- 🐛 Report bugs via [GitHub Issues](https://github.com/ephico2real2/k8s-secret-scanner/issues)
- 💡 Feature requests welcome via [GitHub Discussions](https://github.com/ephico2real2/k8s-secret-scanner/discussions)

## ⚡ Performance Tips

- Use `--only-namespaces` instead of `--skip-namespaces` when targeting specific environments
- Skip system namespaces with `--skip-system-namespaces` for faster searches
- Use specific search terms to reduce false positives

## 🔒 Security Considerations

- This tool reads secret data for text matching - ensure appropriate RBAC permissions
- Output may contain sensitive information - use with care in shared environments  
- Consider using specific namespace targeting instead of cluster-wide searches in production

---

**Made with ❤️ for the Kubernetes community**