#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes
kubectl get pods,svc,ingress -n banking-dev
kubectl get pods,svc -n monitoring || true
helm list -A
