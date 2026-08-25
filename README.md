# 🏦 Banking DevOps Platform 🏦

An enterprise-style DevOps reference implementation demonstrating how a
containerized banking application can be provisioned, secured, deployed,
and operated on AWS using Infrastructure as Code and automated CI/CD.

The project demonstrates practical DevOps and DevSecOps engineering
patterns including:

-   Infrastructure as Code using Terraform
-   Modular AWS infrastructure
-   Containerization with Docker
-   Amazon ECR image management
-   Amazon ECS Fargate
-   Application Load Balancer
-   Native ECS Blue/Green deployments
-   GitHub Actions CI/CD
-   Trivy container security scanning
-   OPA policy validation
-   IAM role-based access
-   CloudWatch logging and monitoring
-   Customer-managed KMS encryption for CloudWatch Logs
-   365-day CloudWatch log retention
-   ALB access logging to a dedicated hardened S3 bucket
-   Checkov Infrastructure-as-Code security scanning
-   Pytest automated application tests with an 80% coverage gate
-   Bandit Python SAST scanning
-   Read-only ECS container root filesystem
-   Private workload networking

------------------------------------------------------------------------

# 1. Project Overview

The Banking DevOps Platform is designed as an enterprise-style
deployment architecture for running containerized applications on AWS.

The platform separates:

-   Application source code
-   Infrastructure code
-   Security policies
-   CI/CD automation
-   Runtime infrastructure

Infrastructure is provisioned using Terraform while application
deployments are performed through GitHub Actions.

The current application workload runs on **Amazon ECS Fargate** behind
an **Application Load Balancer (ALB)**.

Application releases use **ECS native Blue/Green deployment strategy**,
allowing a new application revision to be validated before replacing the
existing production revision.

------------------------------------------------------------------------

# 2. Architecture

``` text
                        Developer
                            │
                            │ Git Push
                            ▼
                    GitHub Repository
                            │
                            ▼
                    GitHub Actions
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
            Build         Trivy          OPA
          Docker Image    Scan        Policy Check
              │
              ▼
         Amazon ECR
              │
              ▼
      ECS Task Definition
              │
              ▼
       Amazon ECS Fargate
              │
        Blue/Green Deployment
              │
        ┌─────┴─────┐
        │           │
        ▼           ▼
   Target Group A  Target Group B
        │           │
        └─────┬─────┘
              │
              ▼
     Application Load Balancer
              │
              ▼
           Users
```

------------------------------------------------------------------------

# 3. AWS Architecture

``` text
Internet
   │
   ▼
Application Load Balancer
Public Subnets
   │
   ▼
ALB Listener : HTTP/80
   │
   ▼
Production Listener Rule
   │
   ├──────── Target Group A
   │
   └──────── Target Group B
                   │
                   ▼
              ECS Fargate
             Private Subnets
                   │
                   ▼
              Application
                Port 5000
```

The ECS tasks do not require public IP addresses.
`map_public_ip_on_launch` is also disabled on both public subnets. The
subnets remain public through Internet Gateway routing, but workloads
are not automatically assigned public IPv4 addresses. This resolves
`CKV_AWS_130`.

Application traffic follows:

``` text
Internet
   ↓
ALB : 80
   ↓
Target Group
   ↓
ECS Task : 5000
```

The ECS security group allows application traffic on port `5000` **only
from the ALB security group**.

------------------------------------------------------------------------

# 4. Repository Structure

``` text
banking-devops-platform/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── app/
│   └── Application source code
│
├── iac/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   │
│   └── modules/
│       ├── vpc/
│       ├── security-group/
│       ├── iam/
│       ├── ecr/
│       ├── ecs/
│       ├── alb/
│       ├── alb-logs/
│       ├── kms/
│       └── cloudwatch/
│
├── policies/
│   └── mandatory-tags.rego
│
├── scripts/
│   └── Automation / validation scripts
│
├── .gitignore
└── README.md
```

------------------------------------------------------------------------

# 5. Technology Stack

  Layer                         Technology
  ----------------------------- ---------------------------
  Cloud Platform                AWS
  Infrastructure as Code        Terraform
  Container Runtime             Docker
  Container Registry            Amazon ECR
  Container Orchestration       Amazon ECS
  Compute                       AWS Fargate
  Load Balancing                Application Load Balancer
  Networking                    Amazon VPC
  Identity & Access             AWS IAM
  Logging / Monitoring          Amazon CloudWatch
  CI/CD                         GitHub Actions
  Application Testing           Pytest / pytest-cov
  Python SAST                   Bandit
  Container Security Scanning   Trivy
  IaC Security Scanning         Checkov
  Policy as Code                Open Policy Agent
  Encryption                    AWS KMS
  ALB Audit Logging             Amazon S3
  Deployment Strategy           ECS Blue/Green

------------------------------------------------------------------------

# 6. Infrastructure Components

## VPC

The Terraform VPC module provisions the network foundation.

``` text
VPC
│
├── Public Subnet 1
├── Public Subnet 2
│
├── Private Subnet 1
├── Private Subnet 2
│
├── Internet Gateway
├── NAT Gateway
│
├── Public Route Table
└── Private Route Table
```

The Application Load Balancer is deployed in public subnets.

ECS Fargate workloads are deployed in private subnets.

This prevents application containers from being directly exposed to the
internet.

------------------------------------------------------------------------

# 7. Security Groups

Two primary security groups are used.

### ALB Security Group

Allows inbound:

``` text
Internet
   │
   │ TCP/80
   ▼
ALB
```

### ECS Task Security Group

Allows:

``` text
ALB Security Group
        │
        │ TCP/5000
        ▼
ECS Tasks
```

Direct public access to ECS application port `5000` is not permitted.

------------------------------------------------------------------------

# 8. IAM Architecture

The project separates IAM responsibilities across multiple ECS roles.

### ECS Execution Role

Used by ECS to perform platform-level operations such as:

-   Pull container images from ECR
-   Write container logs to CloudWatch

### ECS Task Role

Used by the running application when AWS API access is required.

This separates application permissions from ECS platform permissions.

### ECS Infrastructure Role

Used by ECS for infrastructure operations associated with native
Blue/Green deployments.

The role uses the AWS managed policy:

``` text
AmazonECSInfrastructureRolePolicyForLoadBalancers
```

The role is supplied to the ECS service through:

``` text
advanced_configuration.role_arn
```

This allows ECS to manage the load-balancer resources required during
Blue/Green deployment.

------------------------------------------------------------------------

# 9. Amazon ECR

Application container images are stored in Amazon Elastic Container
Registry.

Typical image flow:

``` text
Application Code
      ↓
docker build
      ↓
Security Scan
      ↓
docker push
      ↓
Amazon ECR
      ↓
ECS Task Definition
```

ECR lifecycle management is configured through Terraform to control old
image retention.

------------------------------------------------------------------------

# 10. Amazon ECS Fargate

The application runs using AWS Fargate.

Current container configuration:

``` text
CPU                     : 256
Memory                  : 512 MB
Container Port          : 5000
Network Mode            : awsvpc
Launch Type             : FARGATE
Public IP               : Disabled
Root Filesystem         : Read Only
```

The task definition enables `readonlyRootFilesystem = true`. This
reduces the writable attack surface inside the application container and
resolves Checkov `CKV_AWS_336`.

Container logging uses:

``` text
awslogs
```

and application logs are forwarded to Amazon CloudWatch.

------------------------------------------------------------------------

# 11. Application Load Balancer

The Application Load Balancer provides the public entry point for the
application.

``` text
Client
   ↓
ALB HTTP : 80
   ↓
Listener Rule
   ↓
ECS Target Group
```

The listener contains a production routing rule for application traffic.

A default fixed response is used when no application routing rule
matches.

## ALB Access Logging

ALB access logging is enabled and delivered to a dedicated S3 bucket:

``` text
ALB
 │
 └── Access Logs
       ↓
 Dedicated S3 Log Bucket
       ├── Public Access Blocked
       ├── Server-Side Encryption
       ├── Versioning Enabled
       ├── 365-Day Log Retention
       └── Incomplete Multipart Upload Cleanup: 7 Days
```

The reusable `modules/alb-logs` module provisions the bucket,
public-access controls, encryption, versioning, lifecycle policy, and
ELB log-delivery bucket policy.

This resolves `CKV_AWS_91`. The lifecycle rule also aborts incomplete
multipart uploads after seven days, resolving `CKV_AWS_300`.

------------------------------------------------------------------------

# 12. Blue/Green Deployment

The ECS service uses the native:

``` text
BLUE_GREEN
```

deployment strategy.

Two target groups are configured for the ECS service.

``` text
Current Production
        │
        ▼
Target Group A
        │
        ▼
Current ECS Revision


New Deployment
        │
        ▼
Target Group B
        │
        ▼
New ECS Revision
```

## Deployment Lifecycle

When a new deployment starts:

``` text
Current Production Revision
          │
          │
          │ New deployment
          ▼
Create Green Revision
          │
          ▼
Start Green ECS Tasks
          │
          ▼
Register Green Targets
          │
          ▼
ALB Health Checks
          │
       Healthy?
          │
          ▼
Shift Production Traffic
     Blue ───────► Green
          │
          ▼
       Bake Time
          │
          ▼
Terminate Old Blue Tasks
          │
          ▼
Deployment Complete
```

The project currently uses a **5-minute bake time**.

During bake time, the new revision serves production traffic while the
previous revision remains available temporarily.

After successful completion, ECS terminates the previous Blue tasks.

------------------------------------------------------------------------

# 13. Understanding Blue and Green

Blue and Green should be understood as **deployment roles**, rather than
permanent application versions.

Example:

``` text
Version 1
BLUE
Production
```

Deploy Version 2:

``` text
v1 = BLUE
v2 = GREEN

       ↓

Traffic Shift

       ↓

v2 = Production
v1 = Terminated
```

During the next deployment:

``` text
Current v2 = Existing Production
New v3     = New Deployment Revision
```

The target groups participate alternately in subsequent deployments.

Therefore, application versions should not be permanently associated
with the words Blue or Green.

------------------------------------------------------------------------

# 14. CI/CD Pipeline

Application deployment is automated through GitHub Actions.

High-level pipeline:

``` text
Developer
    │
    ▼
Git Push
    │
    ▼
GitHub Actions
    │
    ├── Checkout Source
    │
    ├── Configure AWS Credentials
    │
    ├── Authenticate to ECR
    │
    ├── Build Docker Image
    │
    ├── Trivy Security Scan
    │
    ├── Push Image to ECR
    │
    ├── Download ECS Task Definition
    │
    ├── Render New Image
    │
    ├── Register Task Definition
    │
    └── Deploy to ECS
              │
              ▼
        Blue/Green Deployment
              │
              ▼
         Production
```

The pipeline waits for ECS deployment completion before reporting
success.

------------------------------------------------------------------------

# 15. DevSecOps Controls

Security checks are integrated into the delivery workflow.

## Trivy

Trivy is used to scan container images for known vulnerabilities.

``` text
Docker Image
     ↓
Trivy Scan
     ↓
Security Validation
     ↓
Push / Deployment
```

This introduces container vulnerability scanning before production
deployment.

## Open Policy Agent

OPA is used for Infrastructure-as-Code policy validation.

Example governance requirements include mandatory resource tags such as:

``` text
Environment
Owner
Project
ManagedBy
```

This demonstrates **Policy as Code**, where infrastructure governance
rules can be validated automatically rather than relying exclusively on
manual review.

## Pytest and Coverage

Application tests run before deployment. The current Flask test suite
validates the home and health endpoints. The pipeline enforces a minimum
coverage threshold of **80%**; the validated implementation achieved
**90% coverage** with all three tests passing.

## Bandit

Bandit performs static security analysis of the Python application. The
Flask service intentionally binds to `0.0.0.0` inside the container so
the ECS/ALB network path can reach it; this behavior is reviewed in the
context of container networking.

## Checkov

Checkov scans Terraform for AWS security and compliance issues. Findings
are remediated in code or explicitly documented as training-environment
risk acceptances.

Implemented remediations:

-   `CKV_AWS_158` --- CloudWatch Logs encrypted using KMS
-   `CKV_AWS_338` --- CloudWatch Logs retained for 365 days
-   `CKV_AWS_336` --- ECS root filesystem read-only
-   `CKV_AWS_130` --- automatic subnet public-IP assignment disabled
-   `CKV_AWS_91` --- ALB access logging enabled
-   `CKV_AWS_300` --- incomplete S3 multipart uploads aborted after
    seven days

------------------------------------------------------------------------

# 16. CloudWatch

CloudWatch provides centralized logging and container monitoring.

The ECS cluster has:

``` text
Container Insights = Enabled
```

Container logs are forwarded using the ECS `awslogs` log driver.

Operational visibility therefore follows:

``` text
Application
     ↓
ECS Container
     ↓
awslogs
     ↓
CloudWatch Logs
     ↓
Customer-Managed KMS Encryption
```

The CloudWatch log group is encrypted using a dedicated customer-managed
KMS key from the reusable `modules/kms` module. KMS key rotation is
enabled and log retention is configured for **365 days**.

These controls resolve `CKV_AWS_158` and `CKV_AWS_338`. CloudWatch Logs
use of the KMS key is constrained by the
`kms:EncryptionContext:aws:logs:arn` condition for the application log
group.

------------------------------------------------------------------------

# 17. Prerequisites

Before deploying the project, install:

``` text
Git
Terraform
AWS CLI
Docker
```

You also require:

-   AWS Account
-   Appropriate AWS IAM permissions
-   GitHub repository access
-   AWS credentials/configuration
-   Docker runtime

Verify:

``` bash
aws --version
terraform version
docker --version
git --version
```

------------------------------------------------------------------------

# 18. AWS Authentication

Configure AWS CLI credentials:

``` bash
aws configure
```

Verify the authenticated identity:

``` bash
aws sts get-caller-identity
```

Always verify the account and region before provisioning infrastructure.

The current implementation uses:

``` text
Region: us-east-1
```

------------------------------------------------------------------------

# 19. Clone Repository

``` bash
git clone <repository-url>

cd banking-devops-platform
```

Switch to the appropriate development branch:

``` bash
git checkout develop
```

------------------------------------------------------------------------

# 20. Provision Infrastructure

Navigate to the Terraform directory:

``` bash
cd iac
```

Format the Terraform configuration:

``` bash
terraform fmt -recursive
```

Initialize Terraform:

``` bash
terraform init
```

Validate:

``` bash
terraform validate
```

Generate an execution plan:

``` bash
terraform plan
```

Review the plan carefully.

Provision infrastructure:

``` bash
terraform apply
```

------------------------------------------------------------------------

# 21. Terraform Module Dependency Flow

The root Terraform configuration connects the modules.

``` text
VPC
 │
 ├────────► Security Groups
 │
 ├────────► ALB
 │
 └────────► ECS
              ▲
              │
IAM ──────────┤
              │
ECR ──────────┤
              │
CloudWatch ───┘
```

For example, the ECS module receives:

``` text
Private subnet IDs
ECS security group
Execution role ARN
Task role ARN
Infrastructure role ARN
ECR repository URL
Blue/Green target groups
Production listener rule
CloudWatch log group
```

This keeps individual Terraform modules reusable while the root module
handles integration.

------------------------------------------------------------------------

# 22. Validate Infrastructure

After deployment:

``` bash
terraform output
```

Expected infrastructure outputs include information such as:

``` text
ALB DNS Name
VPC ID
Public Subnet IDs
Private Subnet IDs
ECS Cluster Name
Task Definition ARN
Target Group ARNs
Listener ARN
```

------------------------------------------------------------------------

# 23. Validate ECS Service

Check ECS service status:

``` bash
aws ecs describe-services \
  --cluster banking-devops-dev-cluster \
  --services banking-devops-dev-service \
  --region us-east-1
```

Confirm that the service reports:

``` text
deployment strategy = BLUE_GREEN
running tasks        = expected count
deployment status    = completed
```

------------------------------------------------------------------------

# 24. Validate Target Health

During a Blue/Green deployment, inspect both ALB target groups.

The incoming revision should transition through:

``` text
Initial
   ↓
Health Checking
   ↓
Healthy
```

Production traffic is shifted only after the required deployment health
conditions are satisfied.

------------------------------------------------------------------------

# 25. Validate Application

Retrieve the ALB DNS name:

``` bash
terraform output alb_dns_name
```

Access:

``` text
http://<ALB-DNS-NAME>
```

Expected application response:

``` text
🏦 Banking DevOps Platform

Project 1

Successfully deployed using

• Terraform
• ECS Fargate
• ECR
• ALB
• CloudWatch
```

------------------------------------------------------------------------

# 26. Deployment Workflow

Normal development flow:

``` text
Developer Change
      ↓
Feature / Development Branch
      ↓
Commit
      ↓
Push
      ↓
GitHub Actions
      ↓
Build
      ↓
Security Validation
      ↓
ECR
      ↓
New ECS Revision
      ↓
Blue/Green Deployment
      ↓
Health Validation
      ↓
Production Traffic Shift
      ↓
Bake
      ↓
Old Revision Terminated
```

------------------------------------------------------------------------

# 27. Troubleshooting

## ECS Task Not Starting

Check:

``` text
ECS Service Events
CloudWatch Logs
Task Definition
Execution Role
ECR Image
Private Subnet/NAT connectivity
Security Groups
```

------------------------------------------------------------------------

## ALB Target Unhealthy

Verify:

``` text
Container is running
Application listens on port 5000
Target group health-check configuration
ALB → ECS security-group access
Application health endpoint
```

------------------------------------------------------------------------

## Blue/Green Role Error

If ECS reports:

``` text
Unable to assume role and validate the specified targetGroupArn
```

verify:

``` text
ECS Infrastructure Role
        ↓
Trust Relationship
        ↓
ecs.amazonaws.com
        ↓
AmazonECSInfrastructureRolePolicyForLoadBalancers
        ↓
advanced_configuration.role_arn
```

------------------------------------------------------------------------

## Terraform Validation

Always run:

``` bash
terraform fmt -recursive
terraform validate
terraform plan
```

before applying infrastructure changes.

------------------------------------------------------------------------

# 28. Security Principles

The implementation follows several enterprise security principles:

-   ECS workloads run in private subnets
-   No public IP is assigned to ECS tasks
-   Application port is accessible only through ALB
-   IAM roles separate platform and application permissions
-   Container images are vulnerability scanned
-   Infrastructure policies are validated using OPA
-   Infrastructure is managed through Terraform
-   Application deployment is automated
-   Runtime logs are centralized in CloudWatch
-   CloudWatch Logs are encrypted using a customer-managed KMS key
-   CloudWatch Logs are retained for 365 days
-   ALB access logs are retained in a dedicated hardened S3 bucket
-   ECS container root filesystems are read-only
-   Public subnets do not auto-assign public IP addresses
-   Terraform is scanned using Checkov
-   Python application code is tested with Pytest and scanned with
    Bandit

------------------------------------------------------------------------

# 29. Current Platform Capabilities

The project currently demonstrates:

-   AWS multi-AZ VPC architecture
-   Public/private subnet separation
-   Internet Gateway and NAT Gateway
-   Application Load Balancer
-   ECS Fargate
-   Amazon ECR
-   IAM execution/task/infrastructure roles
-   CloudWatch logging
-   Container Insights
-   Terraform remote infrastructure management
-   Modular Terraform
-   GitHub Actions CI/CD
-   Docker image build and publishing
-   Trivy vulnerability scanning
-   OPA governance validation
-   ECS native Blue/Green deployment
-   Automated ALB traffic switching
-   Deployment bake period
-   Automatic cleanup of previous ECS revision
-   Pytest automated tests with coverage enforcement
-   Bandit Python static security analysis
-   Checkov - Customer-managed KMS encryption for CloudWatch Logs
-   365-day CloudWatch log retention
-   ALB access logging to hardened S3 storage
-   S3 lifecycle cleanup for incomplete multipart uploads
-   Read-only ECS root filesystem
-   Disabled subnet-level automatic public-IP assignment

------------------------------------------------------------------------

# 30. Security Exceptions and Training-Environment Risk Acceptance

Security findings are not suppressed without a documented reason. This
repository is currently a **development/training environment**, so a
small number of controls are intentionally deferred where implementation
requires production-only dependencies or destructive migration.

  ------------------------------------------------------------------------
  Checkov ID              Status                  Reason / Decision
  ----------------------- ----------------------- ------------------------
  `CKV_AWS_2`             ⚠️ Training exception   The ALB currently
                                                  exposes HTTP/80 because
                                                  no owned DNS domain and
                                                  ACM certificate are
                                                  available. Production
                                                  must use HTTPS/443 with
                                                  an ACM-managed
                                                  certificate and redirect
                                                  HTTP to HTTPS.

  `CKV_AWS_260`           ⚠️ Training exception   Port 80 remains
                                                  internet-accessible as
                                                  the current training
                                                  entry point. Production
                                                  must expose HTTPS/443
                                                  and use port 80 only for
                                                  HTTP-to-HTTPS
                                                  redirection, or remove
                                                  it.

  `CKV_AWS_136`           ⚠️ Deferred             The existing ECR
                                                  repository was created
                                                  without customer-managed
                                                  KMS encryption. Changing
                                                  the encryption
                                                  configuration requires
                                                  repository
                                                  migration/replacement.
                                                  New production
                                                  repositories must be
                                                  created with KMS
                                                  encryption from day one.

  `CKV_AWS_109`           ⚠️ Reviewed exception   Reported against the KMS
                                                  key-policy document. The
                                                  CloudWatch Logs service
                                                  permission is
                                                  constrained by the
                                                  log-group encryption
                                                  context.

  `CKV_AWS_111`           ⚠️ Reviewed exception   Reported against the
                                                  same KMS key-policy
                                                  document. Required KMS
                                                  key-policy semantics are
                                                  retained while service
                                                  use is constrained to
                                                  the intended CloudWatch
                                                  Logs context.

  `CKV_AWS_356`           ⚠️ Reviewed exception   Reported because the KMS
                                                  key policy contains
                                                  `Resource = "*"`. In
                                                  this KMS key-policy
                                                  context, the statement
                                                  applies to the key to
                                                  which the policy is
                                                  attached; the CloudWatch
                                                  service statement is
                                                  further restricted by
                                                  encryption context.
  ------------------------------------------------------------------------

The training CI/CD security scan can use these explicitly documented
exceptions:

``` bash
checkov -d iac \
  --framework terraform \
  --compact \
  --skip-check CKV_AWS_2,CKV_AWS_260,CKV_AWS_136,CKV_AWS_109,CKV_AWS_111,CKV_AWS_356
```

> **Production gate:** These exceptions must be reviewed before
> promotion beyond the training environment. HTTPS/ACM and ECR KMS
> encryption are production requirements.

------------------------------------------------------------------------

# 31. Security Hardening Progress

  -----------------------------------------------------------------------------------
  Control                 Implementation                      Status
  ----------------------- ----------------------------------- -----------------------
  ECS private networking  Fargate tasks in private subnets    ✅ Implemented
                          without public IPs                  

  Subnet public-IP        `map_public_ip_on_launch = false`   ✅ Implemented
  behavior                                                    

  ECS filesystem          `readonlyRootFilesystem = true`     ✅ Implemented
  hardening                                                   

  CloudWatch encryption   Dedicated customer-managed KMS key  ✅ Implemented

  CloudWatch retention    365 days                            ✅ Implemented

  ALB access logging      Dedicated S3 logging bucket         ✅ Implemented

  ALB log-bucket public   S3 Block Public Access              ✅ Implemented
  access                                                      

  ALB log-bucket          Server-side encryption enabled      ✅ Implemented
  encryption                                                  

  ALB log retention       Lifecycle expiration after 365 days ✅ Implemented

  Failed multipart        Abort incomplete uploads after 7    ✅ Implemented
  cleanup                 days                                

  Container vulnerability Trivy                               ✅ Implemented
  scanning                                                    

  Python SAST             Bandit                              ✅ Implemented

  Application testing     Pytest + 80% coverage gate          ✅ Implemented

  IaC governance          OPA                                 ✅ Implemented

  IaC security scanning   Checkov                             ✅ Implemented

  HTTPS/ACM               Deferred until a domain is          ⚠️ Training exception
                          available                           

  ECR customer-managed    Requires repository                 ⚠️ Deferred
  KMS                     migration/replacement               
  -----------------------------------------------------------------------------------

------------------------------------------------------------------------

# 32. Security Validation Commands

``` bash
# Terraform quality checks
terraform fmt -recursive
terraform validate
terraform plan

# Checkov with documented training exceptions
checkov -d . \
  --framework terraform \
  --compact \
  --skip-check CKV_AWS_2,CKV_AWS_260,CKV_AWS_136,CKV_AWS_109,CKV_AWS_111,CKV_AWS_356

# CloudWatch KMS + retention verification
aws logs describe-log-groups \
  --log-group-name-prefix /ecs/banking-devops-dev \
  --region us-east-1 \
  --query 'logGroups[0].{KmsKeyId:kmsKeyId,Retention:retentionInDays}'

# ALB access-log verification
aws elbv2 describe-load-balancer-attributes \
  --load-balancer-arn <ALB-ARN> \
  --region us-east-1 \
  --query "Attributes[?starts_with(Key, 'access_logs')]"
```

Expected CloudWatch posture: customer-managed KMS key present and
retention = `365`.

Expected ALB posture: `access_logs.s3.enabled = true`, dedicated log
bucket configured, and prefix = `alb`.

------------------------------------------------------------------------

# 33. Future Enhancements

The platform is designed to evolve toward a broader enterprise DevOps
reference architecture.

Planned areas can include:

``` text
HTTPS / ACM
Route 53
AWS WAF
Secrets Manager
ECS Auto Scaling
CloudWatch Alarms
SNS Notifications
Automated rollback controls
Enhanced OPA governance
Multi-environment promotion
Kubernetes / EKS
GitOps
Prometheus / Grafana
Disaster Recovery
Cloud Governance
```

------------------------------------------------------------------------

# 34. Engineering Principles

This repository demonstrates the following engineering approach:

> **Build once, validate continuously, deploy safely, observe
> everything, and manage infrastructure as code.**

The objective is not simply to deploy an application, but to demonstrate
how infrastructure, security, deployment automation, governance, and
operational visibility work together in an enterprise DevOps platform.

------------------------------------------------------------------------

# 35. Current Project-1 Status

The project has progressed beyond the initial deployment baseline into
an enterprise-style DevSecOps implementation.

**Completed:** modular Terraform, VPC/public-private networking,
NAT/IGW, security-group separation, ECR, ECS Fargate, ALB, native ECS
Blue/Green, ECS infrastructure role, GitHub Actions deployment,
Pytest/coverage, Bandit, Trivy, OPA, Checkov, CloudWatch Container
Insights/logging, CloudWatch KMS encryption, 365-day retention, ALB
access logging, hardened S3 log storage, read-only container root
filesystem, and subnet public-IP hardening.

**Intentionally deferred for the training environment:** HTTPS/ACM
because no owned domain is currently available, ECR customer-managed KMS
because the existing repository requires migration/replacement, and the
reviewed KMS key-policy scanner exceptions documented above.

**Recommended next engineering increments:** CloudWatch alarms, SNS
notifications, deployment rollback controls, ECS service auto scaling,
Secrets Manager integration, and eventually production DNS/HTTPS/WAF
controls.

------------------------------------------------------------------------

## Project

**Banking DevOps Platform**

Enterprise DevOps / DevSecOps reference implementation on AWS.

**Environment:** Development\
**Cloud:** AWS\
**Primary Region:** `us-east-1`\
**Infrastructure:** Terraform\
**Runtime:** Amazon ECS Fargate\
**CI/CD:** GitHub Actions\
**Deployment Strategy:** Native ECS Blue/Green
