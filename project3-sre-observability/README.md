# Project 3 — SRE Observability Platform on AWS

Enterprise SRE/observability project for the existing Banking EKS workload.

## Scope
- SLO/SLI: availability >= 99.9%, error rate <= 0.1%, p99 latency <= 200 ms
- Prometheus metrics and alert rules
- Grafana SLO dashboard
- CloudWatch Logs, metric filters and alarms
- SNS alert routing
- VPC Flow Logs
- AWS X-Ray / ADOT tracing implementation guide
- k6 incident simulation
- Runbooks, validation scripts and evidence checklist

## Safety / ownership
This project is isolated from Project 1 ECS and Project 2 EKS. It reuses the existing Project 2 EKS cluster/VPC but does not own them. Project 3 Terraform has a separate state key.

## Prerequisites
```bash
aws sts get-caller-identity
terraform version
kubectl version --client
helm version
docker version
aws eks describe-cluster --name banking-eks-dev-cluster --region us-east-1 --query cluster.status
kubectl get nodes
```

## Implementation order
1. Review/edit `terraform/terraform.tfvars`.
2. `terraform -chdir=terraform init && terraform -chdir=terraform validate`
3. `terraform -chdir=terraform plan` and review before apply.
4. Install kube-prometheus-stack in `monitoring` namespace.
5. Build/deploy the instrumented app through Project 2 Helm/GitOps.
6. Validate `/health` and `/metrics`.
7. Import Grafana dashboard.
8. Implement ADOT/X-Ray using `xray/README.md`.
9. Run k6 incident simulation and verify alerts/dashboards.
10. Capture evidence and complete incident runbook/RCA.

## Prometheus/Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

## Terraform
```bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```
Always review destroy plans. Project 3 must never destroy the existing EKS/VPC.
