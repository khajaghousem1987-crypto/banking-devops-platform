#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://localhost:5000}"
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code}\n" "$BASE_URL/simulate-error" || true; done
