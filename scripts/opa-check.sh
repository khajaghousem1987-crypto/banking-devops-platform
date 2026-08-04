#!/bin/bash
 
set -e
 
echo "========================================="
echo "Open Policy Agent (OPA) Policy Validation"
echo "========================================="
 
echo ""
echo "Checking Security Group Policies..."
opa eval \
  --fail-defined \
  --format=pretty \
  -d policies \
  -i iac/tfplan.json \
  "data.terraform.security.deny"
 
echo ""
echo "Checking Mandatory Tag Policies..."
opa eval \
  --fail-defined \
  --format=pretty \
  -d policies \
  -i iac/tfplan.json \
  "data.terraform.tags.deny"
 
echo ""
echo "Checking S3 Policies..."
opa eval \
  --fail-defined \
  --format=pretty \
  -d policies \
  -i iac/tfplan.json \
  "data.terraform.s3.deny"
 
echo ""
echo "========================================="
echo "All OPA Policies Passed Successfully"
echo "========================================="