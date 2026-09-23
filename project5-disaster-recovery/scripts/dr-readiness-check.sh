#!/bin/bash

set -u

PRIMARY_REGION="us-east-1"
DR_REGION="us-west-2"

PRIMARY_VAULT="banking-dr-dev-primary-vault"
DR_VAULT="banking-dr-dev-dr-vault"

FAILURES=0

echo "============================================"
echo " Project 5 - DR Readiness Check"
echo "============================================"

check() {
    if [ "$1" -eq 0 ]; then
        echo "PASS - $2"
    else
        echo "FAIL - $2"
        FAILURES=$((FAILURES + 1))
    fi
}

echo
echo "[1] AWS Authentication"

aws sts get-caller-identity >/dev/null 2>&1
check $? "AWS authentication"

echo
echo "[2] Primary Backup Vault"

aws backup describe-backup-vault \
  --region "$PRIMARY_REGION" \
  --backup-vault-name "$PRIMARY_VAULT" \
  >/dev/null 2>&1

check $? "Primary backup vault exists"

echo
echo "[3] DR Backup Vault"

aws backup describe-backup-vault \
  --region "$DR_REGION" \
  --backup-vault-name "$DR_VAULT" \
  >/dev/null 2>&1

check $? "DR backup vault exists"

echo
echo "[4] Primary Recovery Point"

PRIMARY_COUNT=$(aws backup list-recovery-points-by-backup-vault \
  --region "$PRIMARY_REGION" \
  --backup-vault-name "$PRIMARY_VAULT" \
  --query 'length(RecoveryPoints)' \
  --output text 2>/dev/null)

if [ "${PRIMARY_COUNT:-0}" -gt 0 ]; then
    check 0 "Primary recovery point available"
else
    check 1 "Primary recovery point available"
fi

echo
echo "[5] DR Recovery Point"

DR_COUNT=$(aws backup list-recovery-points-by-backup-vault \
  --region "$DR_REGION" \
  --backup-vault-name "$DR_VAULT" \
  --query 'length(RecoveryPoints)' \
  --output text 2>/dev/null)

if [ "${DR_COUNT:-0}" -gt 0 ]; then
    check 0 "Cross-region DR recovery point available"
else
    check 1 "Cross-region DR recovery point available"
fi

echo
echo "============================================"

if [ "$FAILURES" -eq 0 ]; then
    echo "DR READINESS: PASS"
    echo "============================================"
    exit 0
else
    echo "DR READINESS: FAIL"
    echo "Failed checks: $FAILURES"
    echo "============================================"
    exit 1
fi