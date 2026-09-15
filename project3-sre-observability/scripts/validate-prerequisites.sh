#!/usr/bin/env bash
set -euo pipefail
for c in aws terraform kubectl helm docker git; do command -v "$c" >/dev/null || { echo "MISSING: $c"; exit 1; }; echo "OK: $c"; done
aws sts get-caller-identity
kubectl get nodes
