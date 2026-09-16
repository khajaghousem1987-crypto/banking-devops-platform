# 📊 Project 3 — Enterprise SRE Observability Platform on AWS

## Banking DevOps Platform

Project 3 implements an enterprise-style **Site Reliability Engineering (SRE) and Observability platform** for the Banking application running on Amazon EKS.

The objective is not simply to install monitoring tools. The project demonstrates how an SRE team defines service reliability objectives, collects metrics/logs/traces, detects reliability degradation, generates alerts, investigates incidents, measures error-budget impact, and validates recovery.

---

# 1. Project Overview

The Banking platform is implemented progressively across multiple projects.

```text
Project 1
Banking Application
        |
        v
Amazon ECS Fargate
CI/CD + Security Gates
        |
        v
Project 2
Amazon EKS Platform
Kubernetes + Helm + ALB
        |
        v
Project 3
SRE Observability Platform
        |
        +--> Metrics
        +--> Logs
        +--> Traces
        +--> SLI / SLO
        +--> Error Budget
        +--> Dashboards
        +--> Alerting
        +--> Incident Simulation
```

Project 3 **does not recreate the EKS platform**.

It consumes and observes the infrastructure and Banking workload created in Project 2.

---

# 2. Project Outcome

After completing this project, the environment should provide:

- Banking application running on Amazon EKS
- Application `/health` endpoint
- Application `/metrics` endpoint
- Prometheus metrics collection
- Grafana SRE dashboards
- CloudWatch application logging
- VPC Flow Logs
- CloudWatch metric filters
- CloudWatch alarms
- SNS alert notifications
- AWS X-Ray / OpenTelemetry tracing capability
- Availability SLI
- Error-rate SLI
- Latency SLI
- Defined SLOs
- Error-budget policy
- Synthetic incident generation
- Incident investigation runbook
- Validation scripts
- Operational evidence

The final flow is:

```text
User
 |
 v
Internet-facing ALB
 |
 v
Amazon EKS
 |
 v
Banking Application
 |
 +--------------------------+
 |                          |
 | /metrics                 | Logs
 v                          v
Prometheus              CloudWatch Logs
 |
 v
Grafana

Application
 |
 v
OpenTelemetry / ADOT
 |
 v
AWS X-Ray

AWS Infrastructure
 |
 +--> VPC Flow Logs
 |
 +--> CloudWatch Metrics
 |
 v
CloudWatch Alarm
 |
 v
Amazon SNS
 |
 v
Engineer / On-call Notification
```

---

# 3. Reliability Objectives

Project 3 defines measurable reliability targets.

| SLI | Measurement | SLO |
|---|---|---|
| Availability | Successful requests / total requests | >= 99.9% |
| Error Rate | HTTP 5xx / total requests | <= 0.1% |
| Latency | p99 HTTP request duration | <= 200 ms |

These targets are used for dashboards, alerting, incident analysis, and error-budget calculations.

---

# 4. Observability Pillars

The project implements the three primary observability pillars.

## Metrics

Used for:

- Request volume
- HTTP errors
- Request latency
- Kubernetes health
- Infrastructure health
- SLO measurement

Primary technology:

```text
Prometheus
```

Visualization:

```text
Grafana
```

---

## Logs

Used for:

- Application errors
- Infrastructure troubleshooting
- Network troubleshooting
- Incident investigation

Primary AWS service:

```text
Amazon CloudWatch Logs
```

Additional network telemetry:

```text
VPC Flow Logs
```

---

## Traces

Used for:

- Request tracing
- Dependency analysis
- Latency investigation
- Failure-path investigation

Architecture:

```text
Application
     |
OpenTelemetry / ADOT
     |
AWS X-Ray
```

---

# 5. Repository Structure

```text
project3-sre-observability/
│
├── README.md
├── .gitignore
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── terraform/
│   ├── backend.tf
│   ├── versions.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   │
│   └── modules/
│       │
│       ├── cloudwatch/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       ├── sns/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       │
│       └── vpc-flow-logs/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
├── prometheus/
│   ├── prometheus.yml
│   └── rules/
│       ├── slo-alerts.yml
│       └── infrastructure-alerts.yml
│
├── grafana/
│   ├── dashboards/
│   │   └── banking-slo-dashboard.json
│   │
│   └── provisioning/
│       └── datasources/
│           └── prometheus.yml
│
├── xray/
│   └── README.md
│
├── load-test/
│   └── incident-test.js
│
├── scripts/
│   ├── validate-prerequisites.sh
│   ├── validate-observability.sh
│   └── generate-errors.sh
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SLO-SLI.md
│   ├── ERROR-BUDGET.md
│   └── INCIDENT-RUNBOOK.md
│
├── evidence/
│   └── README.md
│
└── .github/
    └── workflows/
        └── validate.yml
```

---

# 6. Relationship with Previous Projects

## Project 1 — ECS

Project 1 created the original Banking application and AWS ECS/Fargate platform.

Project 3 must **not modify or destroy Project 1 resources**.

---

## Project 2 — EKS

Project 2 migrated/deployed the Banking workload to Amazon EKS.

Project 3 uses the existing:

```text
VPC
Private Subnets
Public Subnets
Amazon EKS Cluster
Managed Node Group
AWS Load Balancer Controller
ALB
Kubernetes Namespace
Banking Deployment
Banking Service
Banking Ingress
Helm deployment
ECR
```

Current expected environment:

```text
AWS Region:
us-east-1

EKS Cluster:
banking-eks-dev-cluster

Namespace:
banking-dev

Application:
banking-app
```

Project 3 adds the observability layer around this workload.

---

# 7. Terraform State Isolation

This is extremely important.

Project 3 uses its own Terraform state:

```text
project3-sre-observability/terraform.tfstate
```

Example backend:

```hcl
terraform {
  backend "s3" {
    bucket  = "banking-infra"
    key     = "project3-sre-observability/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```

Therefore:

```text
Project 1 state
        !=
Project 2 state
        !=
Project 3 state
```

Never copy state files between projects.

Never run Project 3 Terraform from the Project 1 or Project 2 Terraform directory.

---

# 8. Prerequisites

The workstation should contain:

- AWS CLI
- Terraform >= 1.6
- kubectl
- Helm
- Docker
- Git
- Python 3
- curl
- k6 for load testing

Check:

```bash
aws --version
terraform version
kubectl version --client
helm version
docker version
git --version
python3 --version
curl --version
```

Optional:

```bash
k6 version
```

---

# 9. Clone Repository

Example:

```bash
git clone <repository-url>

cd banking-devops-platform/project3-sre-observability
```

Verify:

```bash
pwd
```

Then:

```bash
ls -ltr
```

Expected directories include:

```text
app
terraform
prometheus
grafana
xray
load-test
scripts
docs
evidence
```

---

# 10. AWS Authentication Validation

Before executing Terraform or Kubernetes commands:

```bash
aws sts get-caller-identity
```

Verify:

```text
Account
User/Role ARN
AWS identity
```

Check configured region:

```bash
aws configure get region
```

Project region:

```text
us-east-1
```

If necessary:

```bash
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
```

---

# 11. Validate Existing EKS Cluster

Project 3 depends on Project 2.

Therefore, **do not continue if the EKS cluster is unavailable**.

Run:

```bash
aws eks describe-cluster \
  --name banking-eks-dev-cluster \
  --region us-east-1 \
  --query 'cluster.{Name:name,Status:status,Version:version}' \
  --output table
```

Expected:

```text
Status
ACTIVE
```

Configure kubeconfig:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name banking-eks-dev-cluster
```

Check context:

```bash
kubectl config current-context
```

---

# 12. Validate Kubernetes Nodes

Run:

```bash
kubectl get nodes -o wide
```

All nodes must show:

```text
Ready
```

Detailed validation:

```bash
kubectl describe nodes
```

Pay particular attention to:

```text
Allocatable CPU
Allocatable Memory
Allocatable Pods
```

---

# 13. IMPORTANT — EKS Capacity Validation

Before installing Prometheus/Grafana, verify node capacity.

Run:

```bash
kubectl get pods -A -o wide
```

Then:

```bash
kubectl describe nodes | grep -E "Name:|pods:|Non-terminated Pods" -A 5
```

Project 2 originally used small worker nodes.

A monitoring stack can add several pods, including:

```text
Prometheus
Grafana
Alertmanager
Prometheus Operator
kube-state-metrics
node-exporter
```

If nodes have insufficient pod capacity, new monitoring pods may remain:

```text
Pending
```

with:

```text
Too many pods
```

Do not continue installing additional components until capacity is corrected.

---

# 14. Validate Existing Banking Application

Check namespace:

```bash
kubectl get namespace banking-dev
```

Check workload:

```bash
kubectl get deployment -n banking-dev
```

Expected:

```text
banking-app
```

Check pods:

```bash
kubectl get pods -n banking-dev
```

Expected:

```text
READY   STATUS
1/1     Running
```

Check service:

```bash
kubectl get svc -n banking-dev
```

Expected:

```text
banking-app-service
```

Check ingress:

```bash
kubectl get ingress -n banking-dev
```

Expected:

```text
banking-app-ingress
```

Retrieve ALB:

```bash
kubectl get ingress banking-app-ingress \
  -n banking-dev \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

Test:

```bash
ALB=$(kubectl get ingress banking-app-ingress \
  -n banking-dev \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

curl -I http://$ALB
```

Browser:

```text
http://<ALB-DNS>
```

The Banking application must be healthy before adding observability.

---

# 15. Validate Helm Ownership

Project 2 application is Helm-managed.

Run:

```bash
helm list -n banking-dev
```

Expected:

```text
banking-app
```

Check:

```bash
helm status banking-app -n banking-dev
```

Do not manually modify Helm-managed Kubernetes resources unless required for troubleshooting.

Application changes should eventually flow through:

```text
Git
 ↓
Helm
 ↓
Kubernetes
```

and later:

```text
Git
 ↓
GitOps / Argo CD
 ↓
Helm
 ↓
Kubernetes
```

---

# 16. Project 3 Application Instrumentation

The Project 3 application adds Prometheus instrumentation.

Important endpoints:

```text
/
```

Application homepage.

```text
/health
```

Health endpoint.

```text
/metrics
```

Prometheus metrics endpoint.

```text
/simulate-error
```

Synthetic incident endpoint.

The synthetic endpoint is for controlled DEV/SRE testing only.

---

# 17. Test Application Locally

Enter:

```bash
cd app
```

Create virtual environment:

```bash
python3 -m venv .venv
```

Activate:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run:

```bash
python app.py
```

Test:

```bash
curl http://localhost:5000/
```

Health:

```bash
curl http://localhost:5000/health
```

Metrics:

```bash
curl http://localhost:5000/metrics
```

Expected Prometheus metrics include:

```text
banking_http_requests_total
banking_http_request_duration_seconds
```

Generate synthetic failure:

```bash
curl http://localhost:5000/simulate-error
```

Expected:

```text
HTTP 500
```

Stop local application before proceeding.

---

# 18. Docker Validation

Build:

```bash
docker build \
  -t banking-sre-app:v1.0.0 \
  ./app
```

Check:

```bash
docker images | grep banking-sre
```

Run:

```bash
docker run --rm \
  -p 5000:5000 \
  banking-sre-app:v1.0.0
```

Test:

```bash
curl http://localhost:5000/health
```

and:

```bash
curl http://localhost:5000/metrics
```

---

# 19. Terraform Configuration

Move to:

```bash
cd terraform
```

Review:

```bash
cat terraform.tfvars
```

Expected values include:

```hcl
aws_region       = "us-east-1"
project_name     = "banking-sre"
environment      = "dev"
eks_cluster_name = "banking-eks-dev-cluster"
vpc_id           = "<EXISTING-PROJECT2-VPC>"
```

Never blindly use a VPC ID from documentation.

Verify the actual VPC first.

Example:

```bash
aws eks describe-cluster \
  --name banking-eks-dev-cluster \
  --region us-east-1 \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text
```

Use that result in:

```text
terraform.tfvars
```

---

# 20. Terraform Initialization

Run:

```bash
terraform init
```

Expected:

```text
Terraform has been successfully initialized!
```

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# 21. Review Terraform Plan

Run:

```bash
terraform plan
```

Carefully inspect the plan.

Project 3 should create observability resources such as:

```text
SNS Topic
CloudWatch Log Group
CloudWatch Metric Filter
CloudWatch Alarm
VPC Flow Log Log Group
IAM Role for Flow Logs
IAM Policy
VPC Flow Log
```

It should **NOT destroy**:

```text
EKS Cluster
EKS Node Group
VPC
Subnets
ALB
Banking application
Project 1 ECS infrastructure
```

If Terraform proposes destroying or replacing Project 1/2 infrastructure:

```text
STOP
```

Do not apply.

---

# 22. Terraform Apply

After reviewing the plan:

```bash
terraform apply
```

Confirm:

```text
yes
```

After completion:

```bash
terraform output
```

Expected outputs include:

```text
SNS topic ARN
Application log group
VPC flow log group
```

---

# 23. Validate SNS

Check:

```bash
aws sns list-topics \
  --region us-east-1
```

Expected topic similar to:

```text
banking-sre-dev-alerts
```

If email notification is configured, AWS sends a confirmation email.

The recipient must click:

```text
Confirm subscription
```

Verify:

```bash
aws sns list-subscriptions-by-topic \
  --topic-arn <SNS-TOPIC-ARN> \
  --region us-east-1
```

Status should no longer be:

```text
PendingConfirmation
```

---

# 24. Validate CloudWatch Log Groups

Run:

```bash
aws logs describe-log-groups \
  --region us-east-1 \
  --log-group-name-prefix /banking/
```

Expected Project 3 groups include application and VPC Flow Log groups.

---

# 25. Validate VPC Flow Logs

Run:

```bash
aws ec2 describe-flow-logs \
  --region us-east-1 \
  --filter Name=resource-id,Values=<VPC-ID>
```

Verify:

```text
FlowLogStatus = ACTIVE
TrafficType = ALL
```

VPC Flow Logs help investigate:

```text
ACCEPT traffic
REJECT traffic
Source IP
Destination IP
Source port
Destination port
Network troubleshooting
```

---

# 26. Validate CloudWatch Alarm

Run:

```bash
aws cloudwatch describe-alarms \
  --region us-east-1 \
  --alarm-name-prefix banking-sre
```

The alarm initially may show:

```text
INSUFFICIENT_DATA
```

or:

```text
OK
```

depending on whether metrics have been generated.

---

# 27. Install Prometheus and Grafana

Add Helm repository:

```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
```

Update:

```bash
helm repo update
```

Create namespace:

```bash
kubectl create namespace monitoring
```

If already present:

```text
AlreadyExists
```

is acceptable.

Install:

```bash
helm upgrade --install prometheus \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

---

# 28. Validate Monitoring Components

Run:

```bash
helm list -n monitoring
```

Then:

```bash
kubectl get pods -n monitoring
```

All required pods should eventually become:

```text
Running
```

Check:

```bash
kubectl get svc -n monitoring
```

If any pod remains:

```text
Pending
```

run:

```bash
kubectl describe pod <POD-NAME> -n monitoring
```

Common lab issue:

```text
Too many pods
```

This indicates worker-node capacity, not a Prometheus configuration problem.

---

# 29. Access Grafana

Check service:

```bash
kubectl get svc -n monitoring
```

Port-forward:

```bash
kubectl port-forward \
  -n monitoring \
  svc/prometheus-grafana \
  3000:80
```

Open:

```text
http://localhost:3000
```

Retrieve admin password if required:

```bash
kubectl get secret \
  -n monitoring \
  prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

Do not commit the password to Git.

---

# 30. Grafana Dashboard

Dashboard definition:

```text
grafana/dashboards/banking-slo-dashboard.json
```

The dashboard focuses on:

```text
Request Rate
Error Rate
p99 Latency
```

These represent core SRE signals.

---

# 31. Prometheus Configuration

Reference configuration:

```text
prometheus/prometheus.yml
```

Expected application target:

```text
banking-app-service.banking-dev.svc.cluster.local:80
```

Metrics path:

```text
/metrics
```

Prometheus should ultimately scrape:

```text
http://banking-app-service.banking-dev.svc.cluster.local/metrics
```

---

# 32. Prometheus Alert Rules

SLO alerts are stored in:

```text
prometheus/rules/slo-alerts.yml
```

Examples:

```text
BankingHighErrorRate
BankingP99LatencyHigh
```

Infrastructure rules:

```text
prometheus/rules/infrastructure-alerts.yml
```

Example:

```text
KubernetesNodeNotReady
```

---

# 33. Validate Prometheus

Port-forward Prometheus:

```bash
kubectl get svc -n monitoring | grep prometheus
```

Then use the appropriate service:

```bash
kubectl port-forward \
  -n monitoring \
  svc/prometheus-kube-prometheus-prometheus \
  9090:9090
```

Open:

```text
http://localhost:9090
```

Check:

```text
Status
  -> Targets
```

The Banking application target should show:

```text
UP
```

---

# 34. Core Application Metrics

Prometheus should collect:

```text
banking_http_requests_total
```

and:

```text
banking_http_request_duration_seconds
```

Example request-rate query:

```promql
sum(rate(banking_http_requests_total[5m]))
```

Error-rate query:

```promql
sum(rate(banking_http_requests_total{status=~"5.."}[5m]))
/
clamp_min(
  sum(rate(banking_http_requests_total[5m])),
  0.001
)
```

p99 latency:

```promql
histogram_quantile(
  0.99,
  sum(
    rate(
      banking_http_request_duration_seconds_bucket[5m]
    )
  ) by (le)
)
```

---

# 35. AWS X-Ray / OpenTelemetry

Project 3 uses the modern tracing pattern:

```text
Application
    |
OpenTelemetry SDK
    |
ADOT Collector
    |
AWS X-Ray
```

Detailed tracing notes are stored under:

```text
xray/README.md
```

Do not place:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

inside Kubernetes manifests.

Use AWS-native workload identity mechanisms such as IRSA/workload identity where appropriate.

---

# 36. Incident Simulation

A monitoring platform is incomplete unless alerting is tested.

Project 3 intentionally includes:

```text
/simulate-error
```

Generate errors:

```bash
./scripts/generate-errors.sh http://<ALB-DNS>
```

or:

```bash
for i in {1..20}
do
  curl http://<ALB-DNS>/simulate-error
done
```

This should generate HTTP:

```text
500
```

---

# 37. k6 Load Test

Load-test file:

```text
load-test/incident-test.js
```

Run:

```bash
k6 run \
  -e BASE_URL=http://<ALB-DNS> \
  load-test/incident-test.js
```

The test generates:

```text
Normal requests
+
Synthetic failures
```

---

# 38. Observe the Incident

During the test, observe:

## Prometheus

```text
Request rate increases
Error rate increases
Latency changes
```

## Grafana

Dashboard should visually show the degradation.

## CloudWatch

Review:

```text
Application errors
Metric filter
Alarm state
```

## SNS

Verify alert delivery.

## X-Ray

Inspect:

```text
Trace
Service map
Latency
Failure path
```

---

# 39. Incident Lifecycle

The expected SRE lifecycle is:

```text
Healthy Application
        |
        v
Synthetic Load
        |
        v
Synthetic Errors
        |
        v
SLI Degradation
        |
        v
Prometheus / CloudWatch Detection
        |
        v
Alert Triggered
        |
        v
SNS Notification
        |
        v
Engineer Investigation
        |
        v
Grafana + Logs + Traces
        |
        v
Root Cause Identified
        |
        v
Mitigation
        |
        v
Service Recovery
        |
        v
SLO Revalidated
        |
        v
Error Budget Reviewed
        |
        v
Incident Documentation
```

---

# 40. Error Budget

For:

```text
99.9% availability
```

the unavailable fraction is:

```text
0.1%
```

The error budget helps SRE teams balance:

```text
Feature Delivery
        vs
Reliability
```

Policy is documented in:

```text
docs/ERROR-BUDGET.md
```

---

# 41. Incident Troubleshooting Commands

Start with:

```bash
kubectl get nodes
```

Then:

```bash
kubectl get pods -A
```

Application:

```bash
kubectl get pods -n banking-dev -o wide
```

Deployment:

```bash
kubectl describe deployment banking-app \
  -n banking-dev
```

Logs:

```bash
kubectl logs deployment/banking-app \
  -n banking-dev \
  --tail=100
```

Service:

```bash
kubectl get svc -n banking-dev
```

Ingress:

```bash
kubectl get ingress -n banking-dev
```

Monitoring:

```bash
kubectl get pods -n monitoring
```

Events:

```bash
kubectl get events -A \
  --sort-by=.metadata.creationTimestamp
```

---

# 42. Validation Scripts

Prerequisite validation:

```bash
./scripts/validate-prerequisites.sh
```

Observability validation:

```bash
./scripts/validate-observability.sh
```

These scripts are intended to provide quick operational checks during onboarding and incident troubleshooting.

---

# 43. Evidence Collection

The project should include evidence demonstrating that the implementation actually works.

Store sanitized screenshots/documentation under:

```text
evidence/
```

Recommended evidence:

- EKS nodes Ready
- Banking application Running
- Browser showing healthy Banking application
- `/health` response
- `/metrics` response
- Prometheus target UP
- Prometheus metrics query
- Grafana SLO dashboard
- CloudWatch log group
- VPC Flow Logs ACTIVE
- CloudWatch alarm
- SNS subscription
- Alert notification
- X-Ray service map
- Representative trace
- Synthetic error generation
- Alert firing
- Recovery
- Final healthy application

Never commit:

```text
Passwords
AWS credentials
Tokens
Sensitive customer data
Private production logs
```

---

# 44. CI Validation

GitHub Actions workflow:

```text
.github/workflows/validate.yml
```

The pipeline validates items such as:

```text
Terraform formatting
Terraform initialization
Terraform validation
Python syntax
```

The objective is to catch configuration problems before changes reach the environment.

---

# 45. Git Workflow

Before committing:

```bash
git status
```

Terraform formatting:

```bash
terraform -chdir=terraform fmt -recursive
```

Validation:

```bash
terraform -chdir=terraform init -backend=false
```

```bash
terraform -chdir=terraform validate
```

Commit:

```bash
git add project3-sre-observability
```

```bash
git commit -m "feat: add project3 SRE observability platform"
```

Push:

```bash
git push
```

Prefer pull requests for enterprise workflows.

---

# 46. Troubleshooting — Prometheus/Grafana Pods Pending

Check:

```bash
kubectl get pods -n monitoring
```

Describe:

```bash
kubectl describe pod <POD> -n monitoring
```

If:

```text
0/2 nodes are available: Too many pods
```

the root cause is worker-node pod capacity.

Check:

```bash
kubectl describe nodes | grep -E "Name:|pods:|Non-terminated Pods" -A 5
```

Correct cluster capacity before continuing.

---

# 47. Troubleshooting — Banking Metrics Missing

Test service from inside the cluster:

```bash
kubectl run curl-test \
  --rm -it \
  --restart=Never \
  --image=curlimages/curl \
  -- \
  curl http://banking-app-service.banking-dev.svc.cluster.local/metrics
```

If this fails, investigate:

```text
Application
Service
Selector
Pod readiness
Port mapping
Network policy
```

---

# 48. Troubleshooting — Browser Not Working

Check ingress:

```bash
kubectl get ingress -n banking-dev
```

Check ALB:

```bash
kubectl describe ingress banking-app-ingress \
  -n banking-dev
```

Check endpoints:

```bash
kubectl get endpoints banking-app-service \
  -n banking-dev
```

Endpoints must not be:

```text
<none>
```

---

# 49. Troubleshooting — SNS Email Not Received

Check:

```bash
aws sns list-subscriptions-by-topic \
  --topic-arn <TOPIC-ARN> \
  --region us-east-1
```

If:

```text
PendingConfirmation
```

confirm the AWS subscription email.

---

# 50. Troubleshooting — CloudWatch Alarm Not Firing

Validate:

```text
Metric exists
Metric namespace
Metric filter
Alarm threshold
Evaluation period
SNS action
```

Check:

```bash
aws cloudwatch describe-alarms \
  --region us-east-1
```

---

# 51. Cleanup Strategy

Project 3 Terraform owns **only Project 3 observability resources**.

Before destroying:

```bash
cd terraform
```

Run:

```bash
terraform plan -destroy
```

Review carefully.

It should **NOT propose destruction of**:

```text
Project 1 ECS
Project 1 VPC resources
Project 2 EKS cluster
Project 2 node group
Project 2 ALB
Project 2 ECR
Banking Kubernetes workload
```

Then:

```bash
terraform destroy
```

---

# 52. Helm Monitoring Cleanup

If the monitoring stack needs to be removed:

```bash
helm uninstall prometheus \
  -n monitoring
```

Check:

```bash
kubectl get all -n monitoring
```

Delete namespace only when intentionally cleaning the entire monitoring stack:

```bash
kubectl delete namespace monitoring
```

Do not delete `banking-dev`.

---

# 53. Post-Cleanup Validation

Check Project 3 Terraform:

```bash
terraform state list
```

Then:

```bash
terraform plan -destroy
```

Expected after complete cleanup:

```text
No changes.
No objects need to be destroyed.
```

Now verify Project 2 is still healthy:

```bash
kubectl get nodes
```

```bash
kubectl get pods -n banking-dev
```

```bash
kubectl get ingress -n banking-dev
```

Browser should still reach the Banking application.

---

# 54. Enterprise Operational Principles Demonstrated

This project demonstrates:

### Infrastructure as Code

```text
Terraform
```

### Container orchestration

```text
Amazon EKS
Kubernetes
```

### Application packaging

```text
Docker
```

### Deployment management

```text
Helm
```

### Metrics

```text
Prometheus
```

### Visualization

```text
Grafana
```

### Logging

```text
CloudWatch Logs
```

### Network observability

```text
VPC Flow Logs
```

### Distributed tracing

```text
OpenTelemetry
ADOT
AWS X-Ray
```

### Alerting

```text
Prometheus Alerts
CloudWatch Alarms
Amazon SNS
```

### Reliability engineering

```text
SLI
SLO
Error Budget
Incident Response
```

### Reliability testing

```text
Synthetic Error Injection
k6 Load Testing
```

---

# 55. Definition of Done

Project 3 is considered complete only when all of the following are demonstrated:

- [ ] AWS authentication validated
- [ ] Existing Project 2 EKS cluster ACTIVE
- [ ] Kubernetes nodes Ready
- [ ] Existing Banking application healthy
- [ ] Banking application accessible through ALB
- [ ] Project 3 Terraform state isolated
- [ ] Terraform validate successful
- [ ] Terraform plan reviewed
- [ ] CloudWatch resources created
- [ ] VPC Flow Logs ACTIVE
- [ ] SNS topic created
- [ ] SNS subscription confirmed
- [ ] Prometheus deployed
- [ ] Grafana deployed
- [ ] Banking `/metrics` endpoint available
- [ ] Prometheus Banking target UP
- [ ] Request-rate metric visible
- [ ] Error-rate metric visible
- [ ] p99 latency metric visible
- [ ] Grafana SLO dashboard populated
- [ ] SLO alert rules configured
- [ ] CloudWatch alarm configured
- [ ] OpenTelemetry/X-Ray tracing validated
- [ ] Synthetic errors generated
- [ ] Monitoring detects incident
- [ ] Alert notification received
- [ ] Incident investigated using metrics/logs/traces
- [ ] Application recovery verified
- [ ] Error-budget impact documented
- [ ] Incident runbook validated
- [ ] Evidence captured
- [ ] Git/CI validation successful
- [ ] README updated with final implementation evidence

---

# 56. Final End-to-End Validation

Run:

```bash
aws sts get-caller-identity
```

```bash
aws eks describe-cluster \
  --name banking-eks-dev-cluster \
  --region us-east-1 \
  --query 'cluster.status' \
  --output text
```

Expected:

```text
ACTIVE
```

Then:

```bash
kubectl get nodes
```

All:

```text
Ready
```

Application:

```bash
kubectl get pods -n banking-dev
```

Monitoring:

```bash
kubectl get pods -n monitoring
```

Ingress:

```bash
kubectl get ingress -n banking-dev
```

Prometheus/Grafana:

```bash
helm list -n monitoring
```

Terraform:

```bash
terraform -chdir=terraform output
```

Finally test browser:

```text
Internet
   ↓
AWS ALB
   ↓
Amazon EKS
   ↓
Banking Service
   ↓
Banking Pod
   ↓
Healthy Banking Application
```

At the same time verify:

```text
Banking App
   ├── Metrics → Prometheus → Grafana
   ├── Logs → CloudWatch
   ├── Traces → OpenTelemetry → X-Ray
   └── Reliability Events → Alarm → SNS
```

---

# 57. Project 3 Final Outcome

The completed environment demonstrates a practical enterprise SRE operating model:

```text
BUILD
  ↓
DEPLOY
  ↓
OBSERVE
  ↓
MEASURE SLI
  ↓
COMPARE WITH SLO
  ↓
DETECT DEGRADATION
  ↓
ALERT
  ↓
INVESTIGATE
  ↓
MITIGATE
  ↓
RECOVER
  ↓
MEASURE ERROR BUDGET
  ↓
DOCUMENT & IMPROVE
```

This moves the Banking platform beyond simply **"the application is running"** toward the more important production question:

> **Is the service healthy, reliable, observable, and operating within its defined reliability objectives?**

---

## Project Status

```text
Project 1 — Banking ECS / CI-CD Platform        ✅
Project 2 — Amazon EKS Platform                 ✅
Project 3 — SRE Observability Platform          🚧
Project 4 — AWS Landing Zone                    ⏳
Project 5 — Disaster Recovery & HA              ⏳
```

Update Project 3 to `✅` only after the Definition of Done and end-to-end incident validation are completed.
