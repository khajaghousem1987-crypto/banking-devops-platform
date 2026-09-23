#!/bin/bash

set -euo pipefail

PRIMARY_REGION="us-east-1"
DR_VAULT="banking-dr-dev-dr-vault"

PRIMARY_VAULT="banking-dr-dev-primary-vault"

ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text)

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/banking-dr-dev-backup-role"

DR_VAULT_ARN="arn:aws:backup:us-west-2:${ACCOUNT_ID}:backup-vault:${DR_VAULT}"

echo "Finding latest completed recovery point..."

RECOVERY_POINT_ARN=$(aws backup list-recovery-points-by-backup-vault \
  --region "$PRIMARY_REGION" \
  --backup-vault-name "$PRIMARY_VAULT" \
  --query "reverse(sort_by(RecoveryPoints[?Status=='COMPLETED'], &CreationDate))[0].RecoveryPointArn" \
  --output text)

if [ -z "$RECOVERY_POINT_ARN" ] || [ "$RECOVERY_POINT_ARN" = "None" ]; then
    echo "ERROR: No completed recovery point found."
    exit 1
fi

echo "Source recovery point:"
echo "$RECOVERY_POINT_ARN"

COPY_JOB_ID=$(aws backup start-copy-job \
  --region "$PRIMARY_REGION" \
  --recovery-point-arn "$RECOVERY_POINT_ARN" \
  --source-backup-vault-name "$PRIMARY_VAULT" \
  --destination-backup-vault-arn "$DR_VAULT_ARN" \
  --iam-role-arn "$ROLE_ARN" \
  --query CopyJobId \
  --output text)

echo
echo "Cross-region copy started."
echo "Copy Job ID: $COPY_JOB_ID"

echo
echo "Monitor with:"
echo "aws backup describe-copy-job --region $PRIMARY_REGION --copy-job-id $COPY_JOB_ID"