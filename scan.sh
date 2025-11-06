#!/bin/bash
# k8s-scan - Ultimate "run and done" secret scanner
# Usage: ./scan.sh [search_term] [namespace_pattern]

SEARCH="${1:-ChangeMe}"
NS_PATTERN="${2:-.*}"  # Optional namespace filter

echo "🔍 Scanning for: '$SEARCH'"
[ "$NS_PATTERN" != ".*" ] && echo "📂 Namespaces: $NS_PATTERN"
echo ""

# Get secrets and process in one pipeline
results=$(kubectl get secrets --all-namespaces -o json 2>/dev/null | \
jq -r --arg search "$SEARCH" --arg ns_pattern "$NS_PATTERN" '
.items[] | 
select(.metadata.namespace | test("^(kube-|openshift-|default)") | not) |
select(.metadata.namespace | test($ns_pattern)) |
(.metadata.namespace + "/" + .metadata.name) as $id |
(
  # Check secret name
  if .metadata.name | contains($search) then "✅ \($id) (name)" else empty end,
  # Check data keys and values  
  (.data//{}|to_entries[]? | 
    if .key | contains($search) then "✅ \($id) (key:\(.key))" 
    elif (.value | @base64d | test($search; "i")) then "✅ \($id) (value:\(.key))"
    else empty end
  )
)' 2>/dev/null)

if [ -z "$results" ]; then
  echo "❌ No matches found for '$SEARCH'"
  [ "$NS_PATTERN" != ".*" ] && echo "💡 Try without namespace filter: ./scan.sh $SEARCH"
  exit 1
else
  echo "$results" | head -20  # Limit output
  count=$(echo "$results" | wc -l)
  echo ""
  echo "✅ Found $count matches"
  [ $count -gt 20 ] && echo "📄 (showing first 20 results)"
  echo "💡 Inspect: kubectl get secret <name> -n <namespace> -o yaml"
fi
