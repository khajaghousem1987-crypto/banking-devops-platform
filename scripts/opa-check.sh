#!/bin/bash
 
set -e
 
echo "========================================="
echo "Open Policy Agent (OPA) Policy Validation"
echo "========================================="
 
echo ""
echo "Checking Security Group Policies..."
 
SG=$(opa eval --format=raw \
-d policies \
-i iac/tfplan.json \
"data.terraform.security.deny")
 
echo "$SG"
 
if [ "$SG" != "[]" ]; then
  echo "Security Group Policy Failed"
  exit 1
fi
 
echo ""
echo "Checking Mandatory Tag Policies..."
 
TAG=$(opa eval --format=raw \
-d policies \
-i iac/tfplan.json \
"data.terraform.tags.deny")
 
echo "$TAG"
 
if [ "$TAG" != "[]" ]; then
  echo "Mandatory Tags Policy Failed"
  exit 1
fi
 
echo ""
echo "Checking S3 Policies..."
 
S3=$(opa eval --format=raw \
-d policies \
-i iac/tfplan.json \
"data.terraform.s3.deny")
 
echo "$S3"
 
if [ "$S3" != "[]" ]; then
  echo "S3 Policy Failed"
  exit 1
fi
 
echo ""
echo "========================================="
echo "All OPA Policies Passed Successfully"
echo "========================================="