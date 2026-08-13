# 🏦 Banking DevOps Platform

An enterprise-style DevOps reference implementation demonstrating how a containerized banking application can be provisioned, secured, deployed, and operated on AWS using Infrastructure as Code and automated CI/CD.

The project demonstrates practical DevOps and DevSecOps engineering patterns including:

- Infrastructure as Code using Terraform
- Modular AWS infrastructure
- Containerization with Docker
- Amazon ECR image management
- Amazon ECS Fargate
- Application Load Balancer
- Native ECS Blue/Green deployments
- GitHub Actions CI/CD
- Trivy container security scanning
- OPA policy validation
- IAM role-based access
- CloudWatch logging and monitoring
- Private workload networking

---

# 1. Project Overview

The Banking DevOps Platform is designed as an enterprise-style deployment architecture for running containerized applications on AWS.

The platform separates:

- Application source code
- Infrastructure code
- Security policies
- CI/CD automation
- Runtime infrastructure

Infrastructure is provisioned using Terraform while application deployments are performed through GitHub Actions.

The current application workload runs on **Amazon ECS Fargate** behind an **Application Load Balancer (ALB)**.

Application releases use **ECS native Blue/Green deployment strategy**, allowing a new application revision to be validated before replacing the existing production revision.

---

# 2. Architecture

```text
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

---

# 3. AWS Architecture

```text
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

Application traffic follows:

```text
Internet
   ↓
ALB : 80
   ↓
Target Group
   ↓
ECS Task : 5000
```

The ECS security group allows application traffic on port `5000` **only from the ALB security group**.

---

# 4. Repository Structure

```text
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

---

# 5. Technology Stack

| Layer | Technology |
|---|---|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Container Runtime | Docker |
| Container Registry | Amazon ECR |
| Container Orchestration | Amazon ECS |
| Compute | AWS Fargate |
| Load Balancing | Application Load Balancer |
| Networking | Amazon VPC |
| Identity & Access | AWS IAM |
| Logging / Monitoring | Amazon CloudWatch |
| CI/CD | GitHub Actions |
| Security Scanning | Trivy |
| Policy as Code | Open Policy Agent |
| Deployment Strategy | ECS Blue/Green |

---

# 6. Infrastructure Components

## VPC

The Terraform VPC module provisions the network foundation.

```text
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

This prevents application containers from being directly exposed to the internet.

---

# 7. Security Groups

Two primary security groups are used.

### ALB Security Group

Allows inbound:

```text
Internet
   │
   │ TCP/80
   ▼
ALB
```

### ECS Task Security Group

Allows:

```text
ALB Security Group
        │
        │ TCP/5000
        ▼
ECS Tasks
```

Direct public access to ECS application port `5000` is not permitted.

---

# 8. IAM Architecture

The project separates IAM responsibilities across multiple ECS roles.

### ECS Execution Role

Used by ECS to perform platform-level operations such as:

- Pull container images from ECR
- Write container logs to CloudWatch

### ECS Task Role

Used by the running application when AWS API access is required.

This separates application permissions from ECS platform permissions.

### ECS Infrastructure Role

Used by ECS for infrastructure operations associated with native Blue/Green deployments.

The role uses the AWS managed policy:

```text
AmazonECSInfrastructureRolePolicyForLoadBalancers
```

The role is supplied to the ECS service through:

```text
advanced_configuration.role_arn
```

This allows ECS to manage the load-balancer resources required during Blue/Green deployment.

---

# 9. Amazon ECR

Application container images are stored in Amazon Elastic Container Registry.

Typical image flow:

```text
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

ECR lifecycle management is configured through Terraform to control old image retention.

---

# 10. Amazon ECS Fargate

The application runs using AWS Fargate.

Current container configuration:

```text
CPU             : 256
Memory          : 512 MB
Container Port  : 5000
Network Mode    : awsvpc
Launch Type     : FARGATE
Public IP       : Disabled
```

Container logging uses:

```text
awslogs
```

and application logs are forwarded to Amazon CloudWatch.

---

# 11. Application Load Balancer

The Application Load Balancer provides the public entry point for the application.

```text
Client
   ↓
ALB HTTP : 80
   ↓
Listener Rule
   ↓
ECS Target Group
```

The listener contains a production routing rule for application traffic.

A default fixed response is used when no application routing rule matches.

---

# 12. Blue/Green Deployment

The ECS service uses the native:

```text
BLUE_GREEN
```

deployment strategy.

Two target groups are configured for the ECS service.

```text
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

```text
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

During bake time, the new revision serves production traffic while the previous revision remains available temporarily.

After successful completion, ECS terminates the previous Blue tasks.

---

# 13. Understanding Blue and Green

Blue and Green should be understood as **deployment roles**, rather than permanent application versions.

Example:

```text
Version 1
BLUE
Production
```

Deploy Version 2:

```text
v1 = BLUE
v2 = GREEN

       ↓

Traffic Shift

       ↓

v2 = Production
v1 = Terminated
```

During the next deployment:

```text
Current v2 = Existing Production
New v3     = New Deployment Revision
```

The target groups participate alternately in subsequent deployments.

Therefore, application versions should not be permanently associated with the words Blue or Green.

---

# 14. CI/CD Pipeline

Application deployment is automated through GitHub Actions.

High-level pipeline:

```text
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

The pipeline waits for ECS deployment completion before reporting success.

---

# 15. DevSecOps Controls

Security checks are integrated into the delivery workflow.

## Trivy

Trivy is used to scan container images for known vulnerabilities.

```text
Docker Image
     ↓
Trivy Scan
     ↓
Security Validation
     ↓
Push / Deployment
```

This introduces container vulnerability scanning before production deployment.

## Open Policy Agent

OPA is used for Infrastructure-as-Code policy validation.

Example governance requirements include mandatory resource tags such as:

```text
Environment
Owner
Project
ManagedBy
```

This demonstrates **Policy as Code**, where infrastructure governance rules can be validated automatically rather than relying exclusively on manual review.

---

# 16. CloudWatch

CloudWatch provides centralized logging and container monitoring.

The ECS cluster has:

```text
Container Insights = Enabled
```

Container logs are forwarded using the ECS `awslogs` log driver.

Operational visibility therefore follows:

```text
Application
     ↓
ECS Container
     ↓
awslogs
     ↓
CloudWatch Logs
```

---

# 17. Prerequisites

Before deploying the project, install:

```text
Git
Terraform
AWS CLI
Docker
```

You also require:

- AWS Account
- Appropriate AWS IAM permissions
- GitHub repository access
- AWS credentials/configuration
- Docker runtime

Verify:

```bash
aws --version
terraform version
docker --version
git --version
```

---

# 18. AWS Authentication

Configure AWS CLI credentials:

```bash
aws configure
```

Verify the authenticated identity:

```bash
aws sts get-caller-identity
```

Always verify the account and region before provisioning infrastructure.

The current implementation uses:

```text
Region: us-east-1
```

---

# 19. Clone Repository

```bash
git clone <repository-url>

cd banking-devops-platform
```

Switch to the appropriate development branch:

```bash
git checkout develop
```

---

# 20. Provision Infrastructure

Navigate to the Terraform directory:

```bash
cd iac
```

Format the Terraform configuration:

```bash
terraform fmt -recursive
```

Initialize Terraform:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Generate an execution plan:

```bash
terraform plan
```

Review the plan carefully.

Provision infrastructure:

```bash
terraform apply
```

---

# 21. Terraform Module Dependency Flow

The root Terraform configuration connects the modules.

```text
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

```text
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

This keeps individual Terraform modules reusable while the root module handles integration.

---

# 22. Validate Infrastructure

After deployment:

```bash
terraform output
```

Expected infrastructure outputs include information such as:

```text
ALB DNS Name
VPC ID
Public Subnet IDs
Private Subnet IDs
ECS Cluster Name
Task Definition ARN
Target Group ARNs
Listener ARN
```

---

# 23. Validate ECS Service

Check ECS service status:

```bash
aws ecs describe-services \
  --cluster banking-devops-dev-cluster \
  --services banking-devops-dev-service \
  --region us-east-1
```

Confirm that the service reports:

```text
deployment strategy = BLUE_GREEN
running tasks        = expected count
deployment status    = completed
```

---

# 24. Validate Target Health

During a Blue/Green deployment, inspect both ALB target groups.

The incoming revision should transition through:

```text
Initial
   ↓
Health Checking
   ↓
Healthy
```

Production traffic is shifted only after the required deployment health conditions are satisfied.

---

# 25. Validate Application

Retrieve the ALB DNS name:

```bash
terraform output alb_dns_name
```

Access:

```text
http://<ALB-DNS-NAME>
```

Expected application response:

```text
🏦 Banking DevOps Platform

Project 1

Successfully deployed using

• Terraform
• ECS Fargate
• ECR
• ALB
• CloudWatch
```

---

# 26. Deployment Workflow

Normal development flow:

```text
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

---

# 27. Troubleshooting

## ECS Task Not Starting

Check:

```text
ECS Service Events
CloudWatch Logs
Task Definition
Execution Role
ECR Image
Private Subnet/NAT connectivity
Security Groups
```

---

## ALB Target Unhealthy

Verify:

```text
Container is running
Application listens on port 5000
Target group health-check configuration
ALB → ECS security-group access
Application health endpoint
```

---

## Blue/Green Role Error

If ECS reports:

```text
Unable to assume role and validate the specified targetGroupArn
```

verify:

```text
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

---

## Terraform Validation

Always run:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

before applying infrastructure changes.

---

# 28. Security Principles

The implementation follows several enterprise security principles:

- ECS workloads run in private subnets
- No public IP is assigned to ECS tasks
- Application port is accessible only through ALB
- IAM roles separate platform and application permissions
- Container images are vulnerability scanned
- Infrastructure policies are validated using OPA
- Infrastructure is managed through Terraform
- Application deployment is automated
- Runtime logs are centralized in CloudWatch

---

# 29. Current Platform Capabilities

The project currently demonstrates:

- AWS multi-AZ VPC architecture
- Public/private subnet separation
- Internet Gateway and NAT Gateway
- Application Load Balancer
- ECS Fargate
- Amazon ECR
- IAM execution/task/infrastructure roles
- CloudWatch logging
- Container Insights
- Terraform remote infrastructure management
- Modular Terraform
- GitHub Actions CI/CD
- Docker image build and publishing
- Trivy vulnerability scanning
- OPA governance validation
- ECS native Blue/Green deployment
- Automated ALB traffic switching
- Deployment bake period
- Automatic cleanup of previous ECS revision

---

# 30. Future Enhancements

The platform is designed to evolve toward a broader enterprise DevOps reference architecture.

Planned areas can include:

```text
HTTPS / ACM
Route 53
AWS WAF
Secrets Manager
ECS Auto Scaling
CloudWatch Alarms
SNS Notifications
Automated rollback controls
Enhanced OPA governance
Terraform security scanning
Multi-environment promotion
Kubernetes / EKS
GitOps
Prometheus / Grafana
Disaster Recovery
Cloud Governance
```

---

# 31. Engineering Principles

This repository demonstrates the following engineering approach:

> **Build once, validate continuously, deploy safely, observe everything, and manage infrastructure as code.**

The objective is not simply to deploy an application, but to demonstrate how infrastructure, security, deployment automation, governance, and operational visibility work together in an enterprise DevOps platform.

---

## Project

**Banking DevOps Platform**

Enterprise DevOps / DevSecOps reference implementation on AWS.

**Environment:** Development  
**Cloud:** AWS  
**Primary Region:** `us-east-1`  
**Infrastructure:** Terraform  
**Runtime:** Amazon ECS Fargate  
**CI/CD:** GitHub Actions  
**Deployment Strategy:** Native ECS Blue/Green
