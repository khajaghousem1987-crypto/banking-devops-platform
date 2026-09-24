# Disaster Recovery Failover Procedure

## Purpose
Controlled transition from the primary region `us-east-1` to the DR region `us-west-2`.

## Phase 1 — Detect
EventBridge monitors AWS Backup job, copy job and restore job failures and routes failure events to SNS.

## Phase 2 — Assess
Run:
```bash
./scripts/dr-readiness-check.sh
```

Assess outage scope, business impact, expected primary recovery time and the latest DR recovery point.

## Phase 3 — Declare DR
Obtain required operational authorization and record the DR declaration timestamp.

## Phase 4 — Select Recovery Point
```bash
aws backup list-recovery-points-by-backup-vault   --region us-west-2   --backup-vault-name banking-dr-dev-dr-vault   --output table
```

Choose an appropriate `COMPLETED` recovery point.

## Phase 5 — Restore
```bash
./scripts/restore-from-dr.sh
```

Review restore metadata and perform the approved restore.

## Phase 6 — Validate
Validate resource health, data integrity, IAM, networking, dependencies, monitoring and security controls.

## Phase 7 — Redirect Traffic
Automated Route 53 failover is outside the current lab implementation. In production, traffic-management controls would redirect users to the recovered DR service.

## Phase 8 — Observe
Monitor availability, errors, latency, infrastructure health, security events and data consistency.

## Phase 9 — Evidence
Capture the recovery point, restore job ID, timestamps, validation results and measured recovery duration.
