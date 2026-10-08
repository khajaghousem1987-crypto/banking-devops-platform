# Project 2 — Mandatory Deployment Sequence and Command Runbook

## 1. Deployment principles

This runbook covers two scenarios:

- **Existing environment:** Validate and operate the deployed EKS platform without recreating infrastructure.
- **New environment:** Build the platform in the required dependency order.

**Important:** Project 1 ECS infrastructure and application must remain untouched. Project 2 uses separate Terraform state, application source, ECR repository and Kubernetes workloads.

Current documented DEV environment:

| Parameter | Value |
|---|---|
| AWS account | `500788673290` |
| Region | `us-east-1` |
| EKS cluster | `banking-eks-dev-cluster` |
| Node group | `banking-eks-dev-node-group` |
| Namespace | `banking-dev` |
| ECR repository | `banking-eks-dev-app` |
| Application deployment | `banking-app` |
| Application Service | `banking-app-service` |
| Ingress | `banking-app-ingress` |
| Helm release | `banking-app` |

**Warning:** These values belong to the documented environment. Always check the current AWS identity, cluster and Terraform state before execution.

---

## 2. Phase 1 — AWS authentication

### Step 1: Configure environment variables

```bash
export AWS_REGION=us-east-1
export CLUSTER_NAME=banking-eks-dev-cluster
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

**Why:** Avoids repeatedly typing account, region and cluster identifiers.

### Step 2: Confirm AWS identity

```bash
aws sts get-caller-identity
echo "$ACCOUNT_ID"
```

**Expected:** Account `500788673290`.

**Stop condition:** Do not continue if the account differs.

### Step 3: Verify required tools

```bash
aws --version
terraform version
kubectl version --client
eksctl version
helm version --short
docker --version
git --version
```

**Why:** Confirms the workstation has all tools required for infrastructure provisioning, IAM configuration, Kubernetes deployment and validation.

---

## 3. Phase 2 — Terraform infrastructure

From the repository root:

```bash
cd project2-eks/iac
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

**Why each command is required:**

| Command | Purpose |
|---|---|
| `terraform init` | Initializes the backend, providers and modules |
| `terraform fmt -check -recursive` | Checks Terraform formatting without modifying files |
| `terraform validate` | Validates Terraform configuration syntax and structure |
| `terraform plan` | Shows intended infrastructure changes before approval |

For a **new environment only**, after reviewing and approving the plan:

```bash
terraform apply
```

**Important:** The existing environment already has Terraform-managed infrastructure. Do not apply changes merely to rerun the runbook.

Verify the cluster:

```bash
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.{Status:status,Version:version,VPC:resourcesVpcConfig.vpcId}' \
  --output table
```

Expected cluster status: `ACTIVE`.

Verify the node group:

```bash
aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name banking-eks-dev-node-group \
  --region "$AWS_REGION" \
  --query 'nodegroup.{Status:status,Health:health}' \
  --output json
```

Expected node group status: `ACTIVE`.

---

## 4. Phase 3 — Configure Kubernetes access

```bash
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$CLUSTER_NAME"
```

**Why:** Creates or updates the local kubeconfig context so `kubectl` can communicate with the EKS cluster.

Verify:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

**Expected:** Worker nodes are `Ready`, and core system components such as CoreDNS, kube-proxy and VPC CNI are healthy.

Do not continue with application deployment if cluster networking is unhealthy.

---

## 5. Phase 4 — IAM OIDC provider

### Step 1: Check the cluster OIDC issuer

```bash
aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.identity.oidc.issuer' \
  --output text
```

**Why:** Every EKS cluster has its own OIDC issuer URL. IAM uses this identity to validate Kubernetes ServiceAccount tokens for IRSA.

### Step 2: Check existing IAM OIDC providers

```bash
aws iam list-open-id-connect-providers
```

**Why:** Checks registered IAM providers. Compare the provider ARN suffix with the issuer ID from the previous command.

### Step 3: Associate OIDC — new environment only

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --approve
```

**Why:** Registers the cluster's OIDC issuer in IAM, enabling IAM Roles for Service Accounts.

**Existing environment:** This step was already completed. Do not recreate it.

---

## 6. Phase 5 — AWS Load Balancer Controller IAM policy

The controller requires AWS permissions to discover subnets, manage security groups, create ALBs, configure listeners, register targets and manage target groups.

### Step 1: Check whether the IAM policy exists

```bash
aws iam get-policy \
  --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"
```

If the policy exists, continue to the next phase.

### Step 2: Create the policy — new environment only

Download the **version-matched official AWS Load Balancer Controller IAM policy** from the controller's release documentation, review it and save it as:

`project2-eks/policies/aws-load-balancer-controller-iam-policy.json`

Then execute:

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://aws-load-balancer-controller-iam-policy.json
```

Run this command from the directory containing the policy JSON.

**Why:** The controller needs AWS API permissions, which Kubernetes RBAC alone cannot provide.

**Important:** Do not create a second policy if the correct policy already exists. Confirm the policy matches the controller version being installed.

---

## 7. Phase 6 — IRSA role and controller ServiceAccount

### Step 1: Check existing ServiceAccount

```bash
kubectl get serviceaccount \
  aws-load-balancer-controller \
  -n kube-system \
  -o yaml
```

Look for:

```yaml
eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/AmazonEKSLoadBalancerControllerRole
```

**Why:** This annotation connects the Kubernetes ServiceAccount to an AWS IAM role.

### Step 2: Create IRSA — new environment only

```bash
eksctl create iamserviceaccount \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" \
  --approve
```

**Why:** Creates the IAM role, establishes OIDC trust and associates the role with the controller ServiceAccount.

### Step 3: Verify IAM trust

```bash
aws iam get-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --query 'Role.AssumeRolePolicyDocument'
```

Verify that the trust policy references the correct OIDC provider and restricts access to the intended ServiceAccount:

`system:serviceaccount:kube-system:aws-load-balancer-controller`

**Existing environment:** The IAM role and ServiceAccount were already created successfully. Do not recreate them.

---

## 8. Phase 7 — AWS Load Balancer Controller installation

### Step 1: Add the Helm repository

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

**Why:** Makes the AWS Load Balancer Controller chart available to Helm.

### Step 2: Check existing installation

```bash
helm list -n kube-system

kubectl get deployment \
  aws-load-balancer-controller \
  -n kube-system
```

**Why:** Determines whether the controller is already managed by Helm.

### Step 3: Install — new environment only

```bash
helm upgrade --install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set region="$AWS_REGION" \
  --set vpcId=vpc-03885f609bfdced80 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

**Why:** Installs the Kubernetes controller that translates ALB Ingress resources into AWS load balancer resources.

The `serviceAccount.create=false` setting is critical because the IAM-enabled ServiceAccount was already created during the IRSA phase.

**Version control:** For reproducible deployments, pin a tested Helm chart version rather than automatically accepting the newest version.

### Step 4: Validate controller health

```bash
kubectl rollout status \
  deployment/aws-load-balancer-controller \
  -n kube-system \
  --timeout=180s

kubectl get pods \
  -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller

kubectl logs \
  -n kube-system \
  deployment/aws-load-balancer-controller \
  --tail=100
```

**Expected:** Controller deployment is available and logs show no unresolved AWS IAM or reconciliation errors.

---

## 9. Phase 8 — Verify ALB subnet discovery

Public subnets require:

```text
kubernetes.io/role/elb = 1
```

Private subnets used for internal load balancers require:

```text
kubernetes.io/role/internal-elb = 1
```

Verify:

```bash
aws ec2 describe-subnets \
  --subnet-ids \
  subnet-0faec8b50e5be1d26 \
  subnet-0e1b81d428eeabb25 \
  --query 'Subnets[*].{Subnet:SubnetId,AZ:AvailabilityZone,Tags:Tags}' \
  --output json
```

**Why:** Allows the controller to discover suitable public subnets for the internet-facing ALB.

Ensure the selected subnets have appropriate routes, free IP addresses and availability-zone coverage.

---

## 10. Phase 9 — Build and publish application image

From the repository root:

```bash
cd project2-eks/app
```

Authenticate Docker to ECR:

```bash
aws ecr get-login-password \
  --region "$AWS_REGION" | \
docker login \
  --username AWS \
  --password-stdin \
  "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
```

**Why:** Allows Docker to push the image to the private ECR repository.

Build and push a new immutable version:

```bash
export IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/banking-eks-dev-app"
export IMAGE_TAG=v1.0.2

docker buildx build \
  --platform linux/amd64 \
  --tag "${IMAGE_URI}:${IMAGE_TAG}" \
  --push .
```

**Why:** Builds an image compatible with the documented AMD64 EKS worker nodes.

Verify:

```bash
aws ecr describe-images \
  --repository-name banking-eks-dev-app \
  --region "$AWS_REGION" \
  --image-ids imageTag="$IMAGE_TAG"
```

**Expected:** ECR returns the requested image metadata.

Never reuse an existing immutable image tag.

---

## 11. Phase 10 — Kubernetes manifest deployment

### Important ownership rule

The repository contains both raw Kubernetes YAML and a Helm chart.

**Choose one application deployment method:**

- **Kustomize / kubectl:** Apply the raw manifests and overlays.
- **Helm:** Install or upgrade the banking application Helm release.

Do not manage the same Deployment, Service or Ingress simultaneously through Helm and `kubectl apply`. This can cause ownership conflicts and configuration drift.

### Recommended manifest order

| Order | Manifest | Why it is required |
|---|---|---|
| 1 | `namespace.yaml` | Creates workload isolation |
| 2 | `configmap.yaml` | Supplies non-sensitive application settings |
| 3 | `serviceaccount.yaml` | Defines the application Pod identity |
| 4 | `deployment.yaml` | Creates application Pods |
| 5 | `service.yaml` | Provides stable internal access |
| 6 | `ingress.yaml` | Requests an ALB |
| 7 | `hpa.yaml` | Enables application autoscaling when metrics and capacity are available |
| 8 | `pdb.yaml` | Controls voluntary disruptions when replica capacity supports it |

**Important:** The application ServiceAccount is separate from the AWS Load Balancer Controller ServiceAccount. The banking application does not automatically require an AWS IAM role.

### For raw YAML / Kustomize deployments

From the repository root:

```bash
kubectl apply -f project2-eks/kubernetes/base/namespace.yaml
```

If the remaining optional manifest files have been created and validated, deploy through the development overlay:

```bash
kubectl kustomize project2-eks/kubernetes/overlays/dev
```

**Why:** Renders the effective configuration before deployment.

Then:

```bash
kubectl apply -k project2-eks/kubernetes/overlays/dev
```

**Why:** Applies the declarative development environment configuration.

**Existing environment:** The application is already Helm-managed. Do not execute this raw YAML deployment against the same resources.

---

## 12. Phase 11 — Helm application deployment

From the repository root:

```bash
cd project2-eks/helm/banking-app
```

Validate the chart:

```bash
helm lint .
helm template banking-app . --namespace banking-dev
```

**Why:** Checks chart syntax and previews the rendered Kubernetes manifests.

Check the existing release:

```bash
helm status banking-app -n banking-dev
```

For the existing environment, after reviewing intended chart changes:

```bash
helm upgrade banking-app . \
  --namespace banking-dev
```

**Why:** Updates the existing Helm-managed application without creating a competing deployment.

For a new environment with no existing release:

```bash
helm install banking-app . \
  --namespace banking-dev \
  --create-namespace
```

Do not use `--take-ownership` unless explicitly adopting verified existing resources.

Validate:

```bash
helm list -n banking-dev

kubectl rollout status \
  deployment/banking-app \
  -n banking-dev \
  --timeout=180s
```

**Expected:** Helm release is deployed and application rollout succeeds.

---

## 13. Phase 12 — ALB and application validation

### Step 1: Verify Deployment

```bash
kubectl get deployment banking-app -n banking-dev
```

Expected: desired and available replicas match.

### Step 2: Verify Pods

```bash
kubectl get pods -n banking-dev -o wide
```

Expected: application Pods are Running and Ready.

### Step 3: Verify Service

```bash
kubectl get service banking-app-service -n banking-dev
```

Expected: ClusterIP Service exposes port 80.

### Step 4: Verify EndpointSlices

```bash
kubectl get endpointslices \
  -n banking-dev \
  -l kubernetes.io/service-name=banking-app-service
```

**Why:** Confirms the Service resolves to application Pod endpoints.

### Step 5: Verify Ingress

```bash
kubectl get ingress banking-app-ingress -n banking-dev

kubectl describe ingress banking-app-ingress -n banking-dev
```

Expected: Ingress class `alb` and a populated ALB DNS address.

### Step 6: Verify TargetGroupBinding

```bash
kubectl get targetgroupbinding -n banking-dev
```

**Why:** Confirms the AWS Load Balancer Controller has created the Kubernetes-to-AWS target group binding.

### Step 7: Test the ALB

```bash
ALB=$(kubectl get ingress banking-app-ingress \
  -n banking-dev \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "$ALB"

curl -i "http://${ALB}/"
```

Expected: HTTP 200 and the Project 2 banking application response.

Do not mark the deployment complete until the browser test and ALB target health both succeed.

---

## 14. Phase 13 — HPA and PodDisruptionBudget

These are **planned enhancements**, not automatically part of the completed DEV deployment.

Before enabling HPA:

```bash
kubectl top nodes
kubectl top pods -n banking-dev
```

**Why:** Verifies the Kubernetes metrics pipeline is working.

Check worker capacity:

```bash
kubectl describe nodes
```

The documented `t3.micro` environment has very limited pod capacity. HPA scale-out can leave additional Pods Pending.

A PodDisruptionBudget with `minAvailable: 1` and only one application replica can block voluntary disruptions. Use a production-style PDB only after validating replica count, node capacity and availability requirements.

---

## 15. Phase 14 — Argo CD / GitOps

**Status: Planned; not yet validated.**

Required sequence:

1. Verify sufficient EKS worker capacity.
2. Install Argo CD using a pinned, reviewed installation version.
3. Verify Argo CD components are healthy.
4. Configure GitHub repository access.
5. Create the Argo CD Application manifest.
6. Point the Application to the intended Helm chart or Kustomize overlay.
7. Validate manifest rendering.
8. Perform an initial controlled synchronization.
9. Confirm Argo CD reports `Synced` and `Healthy`.
10. Validate the application through the ALB.

**Critical:** Before enabling Argo CD automated synchronization, confirm it will manage the same resources currently owned by Helm in a controlled handover. Do not introduce a second active deployment manager without a migration plan.

---

## 16. Terraform and eksctl ownership

The existing environment associated the IAM OIDC provider using `eksctl`.

Terraform previously detected the external EKS tag:

```text
alpha.eksctl.io/cluster-oidc-enabled
```

This must be treated as configuration drift until reconciled.

Do not blindly run `terraform apply` to remove or overwrite externally created infrastructure configuration.

For future reproducibility, decide whether IAM OIDC and controller IAM roles will be:

- Managed entirely by Terraform, or
- Managed by documented `eksctl` commands.

Do not create the same IAM role, OIDC provider or Kubernetes ServiceAccount through two separate tools.

---

## 17. Final verification checklist

- [ ] AWS account and region confirmed
- [ ] Terraform state and plan reviewed
- [ ] EKS cluster ACTIVE
- [ ] Node group ACTIVE
- [ ] Worker nodes Ready
- [ ] Kubernetes core components healthy
- [ ] OIDC issuer verified
- [ ] IAM OIDC provider registered
- [ ] Controller IAM policy verified
- [ ] IRSA trust policy verified
- [ ] Controller ServiceAccount annotated
- [ ] AWS Load Balancer Controller healthy
- [ ] Public subnet discovery tags verified
- [ ] ECR image available
- [ ] Application Helm release deployed
- [ ] Application Deployment available
- [ ] Pods Running and Ready
- [ ] Service EndpointSlices populated
- [ ] Ingress ALB DNS populated
- [ ] TargetGroupBinding present
- [ ] ALB target health verified
- [ ] HTTP 200 returned
- [ ] Application validated in browser
- [ ] HPA/PDB status accurately documented
- [ ] Argo CD status accurately documented
- [ ] No Project 1 infrastructure changed

## 18. Definition of Done

The base EKS platform is operational only when the AWS infrastructure, Kubernetes workloads, controller, Ingress, ALB targets and browser-level application validation succeed.

OIDC and IRSA must be documented as mandatory controller prerequisites.

Argo CD, autoscaling, monitoring and production security enhancements must not be represented as completed until individually deployed and validated.

**Operational rule:**

Observe → Validate → Plan → Review → Change → Verify → Document.
