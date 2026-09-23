#!/bin/bash

set -euo pipefail

REGION="us-east-1"

echo "============================================"
echo " Project 5 - Test Resource Cleanup"
echo "============================================"

VOLUME_ID=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --filters \
    "Name=tag:Purpose,Values=DR-Recovery-Test" \
    "Name=status,Values=available" \
  --query 'Volumes[0].VolumeId' \
  --output text)

if [ "$VOLUME_ID" = "None" ] || [ -z "$VOLUME_ID" ]; then
    echo "No available DR test volume found."
    exit 0
fi

echo "Found test volume: $VOLUME_ID"
echo
read -r -p "Delete this test volume? Type yes to continue: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

aws ec2 delete-volume \
  --region "$REGION" \
  --volume-id "$VOLUME_ID"

echo "Deleted: $VOLUME_ID"