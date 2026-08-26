# Project 1 Review and Project 2 Integration Decision

## Decision

Project 1 remains intact. Project 2 receives a separate Terraform root and separate remote-state key, while reading Project 1 outputs through `terraform_remote_state`.

This avoids:

- moving Project 1 Terraform resource addresses
- forcing imports or state migrations
- disturbing the working ECS Blue/Green deployment
- recreating VPC/NAT/ALB/ECR infrastructure unnecessarily

## Project 1 components suitable for reuse

- VPC
- public subnets
- private subnets
- Internet Gateway / NAT routing
- Terraform S3 backend / lock table
- existing tagging conventions
- reusable KMS pattern
- VPC Flow Logs pattern
- security scanning patterns

## Components that should remain Project 1 specific

- ECS service and task definition
- ECS infrastructure role
- ECS Blue/Green target groups
- ECS ALB routing
- ECS task security group

## New Project 2 components

- EKS control plane
- EKS cluster security group rules
- managed node groups
- EKS access entries
- OIDC / IRSA
- EKS add-ons
- AWS Load Balancer Controller and EKS-owned ALB
- Argo CD
- Helm / Kubernetes manifests
- Kubernetes autoscaling and resilience controls
- Kubernetes observability

## Small Project 1 cleanup observations

These should be treated as later cleanup, not blockers for Project 2:

1. `.github/workflows/deploy.yml` contains `KV_AWS_2` in the Checkov skip list; this appears to be a typo for `CKV_AWS_2`.
2. Trivy is configured for table output but the workflow later uploads `reports/trivy-report.txt`; that artifact file is not produced by the current Trivy step.
3. `ssh_cidr` is passed into the security-group module but the current security-group implementation shown does not use SSH ingress.
4. `.terraform.lock.hcl` is ignored. For reproducible provider resolution, committing the lock file is generally preferable.
5. Project 1 workflow constants are intentionally ECS-specific; Project 2 should use its own workflow instead of extending the same deploy job.
