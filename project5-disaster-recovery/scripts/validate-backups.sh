#!/bin/bash

set -euo pipefail

PRIMARY_REGION="us-east-1"
DR_REGION="us-west-2"

PRIMARY_VAULT="banking-dr-dev-primary-vault"
DR_VAULT="banking-dr-dev-dr-vault"

echo "================================================"
echo " Project 5 - AWS Backup Validation"
echo "================================================"

echo
echo "AWS Account:"
aws sts get-caller-identity \
  --query '[Account,Arn]' \
  --output table

echo
echo "Primary Vault:"
aws backup list-backup-vaults \
  --region "$PRIMARY_REGION" \
  --query "BackupVaultList[?BackupVaultName=='$PRIMARY_VAULT'].[BackupVaultName,NumberOfRecoveryPoints]" \
  --output table

echo
echo "Primary Recovery Points:"
aws backup list-recovery-points-by-backup-vault \
  --region "$PRIMARY_REGION" \
  --backup-vault-name "$PRIMARY_VAULT" \
  --query 'RecoveryPoints[*].[ResourceType,Status,CreationDate]' \
  --output table

echo
echo "DR Vault:"
aws backup list-backup-vaults \
  --region "$DR_REGION" \
  --query "BackupVaultList[?BackupVaultName=='$DR_VAULT'].[BackupVaultName,NumberOfRecoveryPoints]" \
  --output table

echo
echo "DR Recovery Points:"
aws backup list-recovery-points-by-backup-vault \
  --region "$DR_REGION" \
  --backup-vault-name "$DR_VAULT" \
  --query 'RecoveryPoints[*].[ResourceType,Status,CreationDate]' \
  --output table

echo
echo "================================================"
echo " Backup validation completed"
echo "================================================"