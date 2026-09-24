# Project 5 — AWS Disaster Recovery & High Availability

## Overview
This project implements a Terraform-managed AWS disaster recovery foundation using AWS Backup, cross-region recovery-point copies, EventBridge/SNS monitoring, EBS recovery testing, and operational automation.

## Project Status
**Implementation: COMPLETE**

Validated:
- Primary AWS Backup vault in `us-east-1`
- DR AWS Backup vault in `us-west-2`
- Tag-based backup selection
- Scheduled backup plan
- Cross-region recovery-point copy
- IAM backup/restore role
- EBS DR test resource
- EventBridge failure monitoring
- SNS alerting
- Backup validation scripts
- DR readiness check
- Multiple completed recovery points in both regions

## Recovery Objectives
| Metric | Target |
|---|---:|
| RTO | 30 minutes |
| RPO | 15 minutes |
| Primary Region | us-east-1 |
| DR Region | us-west-2 |

These are design targets. A timed end-to-end restore is required before claiming measured RTO achievement.

## Architecture
```text
Protected Resource (Backup=true)
          |
          v
    AWS Backup Plan
          |
          v
Primary Vault — us-east-1
          |
   Cross-Region Copy
          |
          v
DR Vault — us-west-2
          |
          v
    Recovery Point
          |
          v
     Restore Process

Backup / Copy / Restore Failure
          |
          v
     EventBridge
          |
          v
         SNS
```

## Repository Structure
```text
project5-disaster-recovery/
├── README.md
├── terraform/
├── scripts/
├── evidence/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DR-STRATEGY.md
│   ├── RTO-RPO.md
│   └── TESTING.md
└── runbooks/
    ├── DR-RUNBOOK.md
    ├── FAILOVER.md
    └── FAILBACK.md
```

## Validation
```bash
./scripts/validate-backups.sh
./scripts/dr-readiness-check.sh
```

Validated result:
```text
PASS - AWS authentication
PASS - Primary backup vault exists
PASS - DR backup vault exists
PASS - Primary recovery point available
PASS - Cross-region DR recovery point available
DR READINESS: PASS
```

Operational validation showed three completed EBS recovery points in the primary vault and three in the DR vault.

## Monitoring
EventBridge rules:
- `banking-dr-dev-backup-failed`
- `banking-dr-dev-copy-failed`
- `banking-dr-dev-restore-failed`

SNS topic:
`banking-dr-dev-dr-alerts`

## RTO/RPO Note
The project proves backup creation, cross-region copy, repeated recovery points, monitoring and DR readiness. A daily backup schedule alone does not guarantee a 15-minute RPO; stricter workloads require an appropriate replication/protection mechanism.

## Final Terraform Validation
```bash
cd terraform
terraform fmt -recursive
terraform validate
terraform plan
```

Expected:
```text
No changes. Your infrastructure matches the configuration.
```

## Definition of Done
- [x] Primary and DR regions configured
- [x] Primary and DR backup vaults deployed
- [x] Backup plan and tag selection configured
- [x] IAM backup/restore role configured
- [x] EBS backup completed
- [x] Cross-region copy completed
- [x] DR recovery points verified
- [x] EventBridge/SNS monitoring configured
- [x] Validation scripts implemented
- [x] DR readiness PASS
- [x] DR/failover/failback runbooks documented
- [ ] Timed end-to-end restore measured
