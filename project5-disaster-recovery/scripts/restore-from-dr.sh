#!/bin/bash

set -euo pipefail

DR_REGION="us-west-2"
DR_VAULT="banking-dr-dev-dr-vault"

echo "============================================"
echo " Project 5 - DR Restore Preparation"
echo "============================================"

RECOVERY_POINT_ARN=$(aws backup list-recovery-points-by-backup-vault \
  --region "$DR_REGION" \
  --backup-vault-name "$DR_VAULT" \
  --query "reverse(sort_by(RecoveryPoints[?Status=='COMPLETED'], &CreationDate))[0].RecoveryPointArn" \
  --output text)

if [ -z "$RECOVERY_POINT_ARN" ] || [ "$RECOVERY_POINT_ARN" = "None" ]; then
    echo "ERROR: No completed DR recovery point found."
    exit 1
fi

echo
echo "Latest DR Recovery Point:"
echo "$RECOVERY_POINT_ARN"

echo
echo "Retrieving restore metadata..."

aws backup get-recovery-point-restore-metadata \
  --region "$DR_REGION" \
  --backup-vault-name "$DR_VAULT" \
  --recovery-point-arn "$RECOVERY_POINT_ARN"

echo
echo "============================================"
echo "Restore metadata retrieved successfully."
echo "Review metadata before starting restore."
echo "============================================"