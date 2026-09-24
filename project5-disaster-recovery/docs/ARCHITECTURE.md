# Project 5 — Disaster Recovery Architecture

## Regions
| Function | Region |
|---|---|
| Primary | us-east-1 |
| DR | us-west-2 |

## Architecture
```text
EBS Test Volume (Backup=true)
        |
        v
AWS Backup Plan
        |
        v
Primary Backup Vault
us-east-1
        |
Cross-Region Copy
        |
        v
DR Backup Vault
us-west-2
        |
        v
Recovery Point
        |
        v
Restore Procedure
```

## Monitoring
```text
Backup/Copy/Restore Failure
        |
        v
EventBridge
        |
        v
SNS
```

## Terraform Scope
Terraform manages backup vaults, plan, selection, IAM role/policies, test EBS volume, SNS topic and EventBridge monitoring rules.

## State Isolation
Project 5 has its own Terraform lifecycle and does not modify Projects 1–4.

## Production Evolution
Route 53 failover, warm standby compute, multi-region applications and cross-region database replication can extend this foundation.
