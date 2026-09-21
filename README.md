# Project 4 --- Enterprise AWS Landing Zone & Multi-Account Governance

## Overview

This project implements an enterprise-style AWS Landing Zone foundation
using AWS Organizations, Organizational Units (OUs), Service Control
Policies (SCPs), AWS CloudTrail, Amazon S3, AWS Config, Amazon
GuardDuty, AWS Security Hub, AWS Budgets, and Terraform.

The goal is to establish a governed AWS foundation before workload teams
deploy applications. The implementation is intentionally safe for a lab:
the AWS Organization and OU hierarchy are real, but unnecessary member
accounts are not created. The design can later evolve into dedicated
Management, Log Archive, Security/Audit, Shared Services, Development,
UAT, and Production accounts.

> **Safety:** AWS Organizations and SCP changes can have
> organization-wide impact. Always review `terraform plan` before
> applying. Test restrictive SCPs against a non-production OU before
> wider rollout.

------------------------------------------------------------------------

## Project Outcome

The completed implementation provides:

-   AWS Organization with all features enabled.
-   Security, Infrastructure, and Workloads OUs.
-   Development, UAT, and Production child OUs.
-   Terraform-managed OU hierarchy.
-   SCP guardrails with controlled rollout to Development.
-   Multi-region CloudTrail.
-   Dedicated encrypted, private, versioned S3 audit bucket.
-   AWS Config configuration recording and S3 delivery.
-   GuardDuty threat detection.
-   Security Hub security posture management.
-   Monthly AWS Budget.
-   Terraform-based deployment, outputs, validation, and drift
    detection.

## Architecture

``` text
AWS Organization
|
+-- Security OU
|
+-- Infrastructure OU
|
+-- Workloads OU
    +-- Development OU
    +-- UAT OU
    +-- Production OU

Governance / Security Baseline
|
+-- Service Control Policies
|
+-- AWS CloudTrail
|   +-- Dedicated S3 audit bucket
|       +-- Public access blocked
|       +-- Encryption
|       +-- Versioning
|       +-- TLS enforcement
|
+-- AWS Config
|   +-- Configuration Recorder
|   +-- Delivery Channel
|   +-- Dedicated S3 bucket
|
+-- Amazon GuardDuty
|
+-- AWS Security Hub
|
+-- AWS Budgets
```

### Production evolution

A production organization would normally evolve toward:

``` text
Management Account
|
+-- Security OU
|   +-- Log Archive Account
|   +-- Security / Audit Account
|
+-- Infrastructure OU
|   +-- Shared Services Account
|
+-- Workloads OU
    +-- Development Account(s)
    +-- UAT Account(s)
    +-- Production Account(s)
```

CloudTrail and Config data can then be centralized in the Log Archive
account, while GuardDuty and Security Hub administration can be
delegated to a Security account.

------------------------------------------------------------------------

## Repository Structure

``` text
project4-aws-landing-zone/
├── README.md
├── .gitignore
├── policies/
│   └── scp/
│       ├── deny-disable-security-services.json
│       ├── prevent-org-exit.json
│       ├── protect-cloudtrail.json
│       └── protect-config.json
├── scripts/
│   ├── validate-prerequisites.sh
│   ├── validate-organization.sh
│   ├── validate-security.sh
│   └── validate-logging.sh
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ACCOUNT-STRATEGY.md
│   ├── SCP-STRATEGY.md
│   ├── SECURITY-BASELINE.md
│   ├── LOGGING-STRATEGY.md
│   └── OPERATIONS-RUNBOOK.md
├── evidence/
│   └── README.md
└── terraform/
    ├── versions.tf
    ├── provider.tf
    ├── backend.tf
    ├── data.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── organization.tf
    ├── scp.tf
    ├── security-baseline.tf
    ├── outputs.tf
    └── modules/
        ├── organizational-unit/
        ├── scp/
        ├── logging/
        ├── config/
        ├── security/
        └── budget/
```

------------------------------------------------------------------------

## Service Responsibilities

### AWS Organizations and OUs

AWS Organizations supplies the enterprise hierarchy. OUs group accounts
by purpose so governance can be applied consistently instead of account
by account.

Implemented hierarchy:

``` text
Root
├── Security
├── Infrastructure
└── Workloads
    ├── Development
    ├── UAT
    └── Production
```

### Service Control Policies

SCPs establish organization-level permission boundaries. They do not
grant permissions. An IAM principal still needs IAM authorization, and
the SCP defines the maximum permissions available to accounts under its
target.

This project starts with a security-service protection policy and
attaches it to Development first to reduce blast radius.

### CloudTrail

CloudTrail provides AWS API audit history. The implementation enables a
multi-region trail, global service events, management events, and
log-file validation.

### Amazon S3

Dedicated S3 buckets store CloudTrail and Config data. Public access is
blocked, server-side encryption and versioning are enabled, and insecure
transport is denied.

### AWS Config

AWS Config records supported AWS resource configuration and
configuration changes. The project provisions the IAM role, recorder,
delivery channel, S3 destination, and recorder status.

### GuardDuty and Security Hub

GuardDuty provides managed threat detection. Security Hub provides
centralized security findings and posture visibility.

### AWS Budgets

The budget module adds basic FinOps governance with a monthly cost limit
and optional email notifications.

------------------------------------------------------------------------

## Prerequisites

Install:

-   AWS CLI v2
-   Terraform
-   Git
-   jq

Verify:

``` bash
aws --version
terraform version
git --version
jq --version
```

Confirm AWS authentication:

``` bash
aws sts get-caller-identity
```

Confirm the intended region:

``` bash
aws configure get region
```

This implementation uses `us-east-1`.

**Never continue until `aws sts get-caller-identity` shows the intended
AWS account.**

------------------------------------------------------------------------

## Clone and Start

``` bash
git clone <YOUR_REPOSITORY_URL>
cd banking-devops-platform/project4-aws-landing-zone
```

If validation scripts are included:

``` bash
chmod +x scripts/*.sh
./scripts/validate-prerequisites.sh
```

Check whether the account is already in an AWS Organization:

``` bash
aws organizations describe-organization
```

If an Organization exists, inspect it:

``` bash
aws organizations list-roots
aws organizations list-accounts
```

If the account is not in an Organization, AWS returns
`AWSOrganizationsNotInUseException`.

For an authorized lab/management account only, create an Organization:

``` bash
aws organizations create-organization   --feature-set ALL
```

Verify:

``` bash
aws organizations describe-organization
```

Do not create an Organization blindly in an enterprise account. Confirm
the organization design and management-account ownership first.

------------------------------------------------------------------------

## Discover the Root

``` bash
aws organizations list-roots
```

Export the root ID:

``` bash
export ROOT_ID=$(aws organizations list-roots   --query 'Roots[0].Id'   --output text)

echo "$ROOT_ID"
```

The value looks like `r-xxxx`.

------------------------------------------------------------------------

## Terraform Configuration

``` bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Example:

``` hcl
project_name = "banking-landing-zone"
home_region  = "us-east-1"

cloudtrail_bucket_name = "REPLACE-WITH-GLOBALLY-UNIQUE-CLOUDTRAIL-BUCKET"
config_bucket_name      = "REPLACE-WITH-GLOBALLY-UNIQUE-CONFIG-BUCKET"

budget_limit_usd = 100
budget_email     = ""
```

S3 bucket names are globally unique. A practical naming convention is:

``` text
<project>-cloudtrail-<account-id>
<project>-config-<account-id>
```

Do not commit environment-specific secrets or sensitive values in
`terraform.tfvars`.

------------------------------------------------------------------------

## Terraform Workflow

Format:

``` bash
terraform fmt -recursive
```

Initialize:

``` bash
terraform init
```

Validate:

``` bash
terraform validate
```

Expected:

``` text
Success! The configuration is valid.
```

Plan:

``` bash
terraform plan
```

For controlled deployments, save the plan:

``` bash
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

A saved plan ensures the reviewed plan is the plan being applied.

------------------------------------------------------------------------

## OU Deployment and Validation

Terraform creates:

``` text
Root
├── Security
├── Infrastructure
└── Workloads
    ├── Development
    ├── UAT
    └── Production
```

Validate top-level OUs:

``` bash
ROOT_ID=$(aws organizations list-roots   --query 'Roots[0].Id'   --output text)

aws organizations list-organizational-units-for-parent   --parent-id "$ROOT_ID"   --query 'OrganizationalUnits[*].[Name,Id]'   --output table
```

Get the Workloads OU:

``` bash
WORKLOADS_OU=$(terraform output -raw workloads_ou_id)
echo "$WORKLOADS_OU"
```

Validate child OUs:

``` bash
aws organizations list-organizational-units-for-parent   --parent-id "$WORKLOADS_OU"   --query 'OrganizationalUnits[*].[Name,Id]'   --output table
```

Expected logical result: Development, UAT, and Production.

------------------------------------------------------------------------

## Enable SCPs

Check whether SCPs are enabled:

``` bash
aws organizations list-roots   --query 'Roots[0].PolicyTypes'   --output table
```

If required:

``` bash
aws organizations enable-policy-type   --root-id "$ROOT_ID"   --policy-type SERVICE_CONTROL_POLICY
```

Verify again:

``` bash
aws organizations list-roots   --query 'Roots[0].PolicyTypes'   --output table
```

Expected: `SERVICE_CONTROL_POLICY` with status `ENABLED`.

------------------------------------------------------------------------

## SCP Guardrail

The initial policy protects security services from selected destructive
operations such as stopping/deleting CloudTrail and stopping/deleting
AWS Config components.

The rollout pattern is deliberately:

``` text
Write policy
  -> Validate JSON
  -> Terraform plan
  -> Create policy
  -> Attach to Development
  -> Test
  -> Observe
  -> Promote only after validation
```

Retrieve the deployed policy:

``` bash
SCP_ID=$(terraform output -raw development_security_scp_id)
echo "$SCP_ID"
```

Validate attachment:

``` bash
aws organizations list-targets-for-policy   --policy-id "$SCP_ID"   --query 'Targets[*].[Name,TargetId,Type]'   --output table
```

The target should be the Development OU.

### SCP principles

-   SCPs do not grant permissions.
-   SCPs limit the maximum permissions available to affected member
    accounts.
-   Roll out new restrictive policies gradually.
-   Maintain break-glass/recovery planning.
-   Do not use the Organization root as the first test target.

------------------------------------------------------------------------

## CloudTrail Verification

Retrieve the trail:

``` bash
TRAIL=$(terraform output -raw cloudtrail_name)
echo "$TRAIL"
```

Status:

``` bash
aws cloudtrail get-trail-status   --name "$TRAIL"   --query '[IsLogging,LatestDeliveryTime,LatestDeliveryError]'   --output table
```

`IsLogging` should be `True`.

Configuration:

``` bash
aws cloudtrail get-trail   --name "$TRAIL"   --query 'Trail.[Name,S3BucketName,IsMultiRegionTrail,LogFileValidationEnabled]'   --output table
```

Multi-region and log-file validation should be enabled.

### CloudTrail S3 security

``` bash
CT_BUCKET=$(terraform output -raw cloudtrail_bucket_name)

aws s3api get-public-access-block   --bucket "$CT_BUCKET"

aws s3api get-bucket-versioning   --bucket "$CT_BUCKET"

aws s3api get-bucket-encryption   --bucket "$CT_BUCKET"
```

Check delivered objects:

``` bash
aws s3 ls "s3://$CT_BUCKET/AWSLogs/" --recursive | head
```

CloudTrail delivery is asynchronous, so new objects may take time to
appear.

------------------------------------------------------------------------

## AWS Config Verification

Recorder:

``` bash
aws configservice describe-configuration-recorder-status   --query 'ConfigurationRecordersStatus[*].[name,recording,lastStatus,lastStartTime]'   --output table
```

`recording` should be `True`.

Delivery channel:

``` bash
aws configservice describe-delivery-channels   --query 'DeliveryChannels[*].[name,s3BucketName]'   --output table
```

Config S3 bucket:

``` bash
CONFIG_BUCKET=$(terraform output -raw config_bucket_name)

aws s3api get-public-access-block   --bucket "$CONFIG_BUCKET"

aws s3api get-bucket-versioning   --bucket "$CONFIG_BUCKET"

aws s3api get-bucket-encryption   --bucket "$CONFIG_BUCKET"
```

------------------------------------------------------------------------

## GuardDuty Verification

``` bash
GD_ID=$(terraform output -raw guardduty_detector_id)
echo "$GD_ID"

aws guardduty get-detector   --detector-id "$GD_ID"   --query '[Status,FindingPublishingFrequency]'   --output table
```

Expected status: `ENABLED`.

------------------------------------------------------------------------

## Security Hub Verification

``` bash
aws securityhub describe-hub   --query '[HubArn,AutoEnableControls,ControlFindingGenerator]'   --output table
```

A valid Hub ARN confirms Security Hub is enabled.

------------------------------------------------------------------------

## Budget Verification

``` bash
ACCOUNT_ID=$(aws sts get-caller-identity   --query Account   --output text)

aws budgets describe-budgets   --account-id "$ACCOUNT_ID"   --query 'Budgets[*].[BudgetName,BudgetLimit.Amount,BudgetLimit.Unit,TimeUnit]'   --output table
```

Expected logical result:

``` text
banking-landing-zone-monthly-budget    100    USD    MONTHLY
```

Budgets provide visibility/notifications. A budget does not
automatically shut down AWS resources.

------------------------------------------------------------------------

## End-to-End Validation

Run:

``` bash
terraform output
aws organizations describe-organization
aws organizations list-roots
```

Validate SCP:

``` bash
SCP_ID=$(terraform output -raw development_security_scp_id)

aws organizations list-targets-for-policy   --policy-id "$SCP_ID"
```

Validate CloudTrail:

``` bash
TRAIL=$(terraform output -raw cloudtrail_name)
aws cloudtrail get-trail-status --name "$TRAIL"
```

Validate Config:

``` bash
aws configservice describe-configuration-recorder-status
```

Validate GuardDuty:

``` bash
GD_ID=$(terraform output -raw guardduty_detector_id)
aws guardduty get-detector --detector-id "$GD_ID"
```

Validate Security Hub:

``` bash
aws securityhub describe-hub
```

Validate Budget:

``` bash
aws budgets describe-budgets   --account-id "$(aws sts get-caller-identity --query Account --output text)"
```

Finally:

``` bash
terraform plan
```

Desired final result:

``` text
No changes. Your infrastructure matches the configuration.
```

------------------------------------------------------------------------

## Terraform State Strategy

Terraform state maps configuration to deployed AWS resources and must be
protected.

Do not:

-   Commit `terraform.tfstate`.
-   Manually edit state.
-   Publish state.
-   Reuse another project's state key.

For enterprise/team usage, use a dedicated encrypted remote backend with
state locking.

Example:

``` hcl
terraform {
  backend "s3" {
    bucket       = "REPLACE-landing-zone-terraform-state"
    key          = "project4/landing-zone/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Bootstrap the backend separately. Project 4 should use its own state and
must not reuse Project 1, 2, or 3 state.

------------------------------------------------------------------------

## CI/CD Strategy

A safe pull-request pipeline should initially run:

``` bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Validate policy JSON:

``` bash
find ../policies -name '*.json' -print0 |
while IFS= read -r -d '' file; do
  jq empty "$file"
done
```

Recommended flow:

``` text
Feature Branch
  -> Pull Request
  -> fmt / validate / policy checks
  -> Terraform Plan
  -> Human Approval
  -> Protected Deployment Identity
  -> Terraform Apply
```

Do not automatically apply Organization/SCP changes from arbitrary
branches.

------------------------------------------------------------------------

## Enterprise Extensions

The lab baseline can be expanded with:

-   Dedicated Log Archive account.
-   Dedicated Security/Audit account.
-   Shared Services account.
-   IAM Identity Center.
-   Delegated administrators.
-   Organization-wide CloudTrail.
-   AWS Config aggregator.
-   GuardDuty organization configuration.
-   Security Hub organization configuration.
-   EventBridge/SIEM integration.
-   KMS customer-managed keys where required.
-   S3 Object Lock where immutable audit retention is required.
-   Backup policies.
-   Tag policies.
-   Account vending.
-   Mandatory tagging.
-   Root-user controls.
-   Break-glass access.
-   MFA governance.
-   Cost allocation tags and anomaly detection.
-   Central network/DNS/egress governance.

These should be implemented according to enterprise requirements rather
than enabled blindly.

------------------------------------------------------------------------

## Why the Lab Does Not Create Multiple Member Accounts

Creating Security, Log Archive, Shared Services, Development, UAT, and
Production accounts adds account lifecycle, email, billing, IAM
bootstrap, cleanup, and governance complexity.

This project therefore demonstrates the organization and OU governance
model without creating unnecessary accounts. In production, member
accounts are placed into the appropriate OUs and inherit applicable
policies.

------------------------------------------------------------------------

## Troubleshooting

### `AWSOrganizationsNotInUseException`

The account is not part of an Organization.

For an authorized lab management account:

``` bash
aws organizations create-organization   --feature-set ALL
```

### `PolicyTypeNotEnabledException`

Check:

``` bash
aws organizations list-roots   --query 'Roots[0].PolicyTypes'
```

Enable:

``` bash
aws organizations enable-policy-type   --root-id "$ROOT_ID"   --policy-type SERVICE_CONTROL_POLICY
```

Then rerun:

``` bash
terraform plan
terraform apply
```

If Terraform already created the SCP before the attachment failed, the
next plan should normally contain only the missing attachment.

### Terraform `file()` path error

If Terraform lives in:

``` text
project4-aws-landing-zone/terraform/
```

and policies live in:

``` text
project4-aws-landing-zone/policies/scp/
```

use:

``` hcl
policy_content = file(
  "${path.module}/../policies/scp/deny-disable-security-services.json"
)
```

### Missing module argument

Inspect that module's `variables.tf`. Inputs should belong to the
correct module. For example, budget limits belong to the budget module,
not the GuardDuty/Security Hub module.

### S3 bucket already exists

S3 names are globally unique. Change the CloudTrail or Config bucket
name.

### CloudTrail bucket initially empty

Confirm:

``` bash
aws cloudtrail get-trail-status --name "$TRAIL"
```

If logging is true and there is no delivery error, allow time for
asynchronous log delivery.

### Config not recording

Check:

``` bash
aws configservice describe-configuration-recorder-status
aws configservice describe-delivery-channels
```

Then inspect the Config IAM role and S3 bucket policy.

------------------------------------------------------------------------

## Operational Ownership

``` text
Cloud Platform Team
├── Organizations / OUs
├── Terraform modules
├── Landing-zone baseline
└── Platform governance

Security Team
├── SCP requirements
├── GuardDuty
├── Security Hub
├── Audit logging
└── Compliance

Application Teams
├── Workload resources
├── Application IAM
├── Tags
└── Guardrail compliance

FinOps
├── Budgets
├── Cost allocation
├── Forecasting
└── Optimization
```

------------------------------------------------------------------------

## Evidence to Capture

Useful portfolio/audit evidence:

``` text
01-organization.png
02-root-and-ous.png
03-workloads-child-ous.png
04-scp-policy.png
05-scp-development-attachment.png
06-cloudtrail-status.png
07-cloudtrail-s3-security.png
08-config-recorder.png
09-config-delivery-channel.png
10-guardduty-enabled.png
11-security-hub.png
12-budget.png
13-terraform-output.png
14-final-terraform-plan-no-changes.png
```

Never capture credentials, secret keys, session tokens, passwords, or
sensitive Terraform values.

------------------------------------------------------------------------

## Cleanup

Do not blindly destroy an enterprise Landing Zone.

First:

``` bash
terraform plan -destroy
```

For a disposable lab only, after reviewing all resources:

``` bash
terraform destroy
```

The Organization itself was intentionally created manually in this
implementation and should not be automatically removed by Terraform.
Organization deletion should be handled as a separate, controlled
administrative operation after checking member-account and AWS
Organizations requirements.

------------------------------------------------------------------------

## Definition of Done

-   [x] AWS Organization exists with ALL features.
-   [x] Security OU exists.
-   [x] Infrastructure OU exists.
-   [x] Workloads OU exists.
-   [x] Development OU exists.
-   [x] UAT OU exists.
-   [x] Production OU exists.
-   [x] SCP policy type is enabled.
-   [x] Security-service protection SCP exists.
-   [x] SCP is attached to Development.
-   [x] CloudTrail is enabled and logging.
-   [x] CloudTrail is multi-region.
-   [x] CloudTrail log-file validation is enabled.
-   [x] CloudTrail S3 bucket is private, encrypted, and versioned.
-   [x] AWS Config recorder is enabled.
-   [x] AWS Config delivery channel exists.
-   [x] Config S3 bucket is protected.
-   [x] GuardDuty is enabled.
-   [x] Security Hub is enabled.
-   [x] Monthly Budget exists.
-   [x] Terraform outputs are available.
-   [x] Final Terraform plan contains no unintended changes.

------------------------------------------------------------------------
