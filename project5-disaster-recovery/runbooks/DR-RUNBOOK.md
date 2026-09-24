# Disaster Recovery Runbook

## 1. Purpose
This runbook defines the operational procedure for responding to a disaster affecting the primary AWS region.

- Primary Region: `us-east-1`
- DR Region: `us-west-2`
- RTO Target: 30 minutes
- RPO Target: 15 minutes

## 2. Initial Assessment
Verify AWS access and DR readiness:

```bash
aws sts get-caller-identity
./scripts/dr-readiness-check.sh
./scripts/validate-backups.sh
```

Expected readiness result:
```text
PASS - AWS authentication
PASS - Primary backup vault exists
PASS - DR backup vault exists
PASS - Primary recovery point available
PASS - Cross-region DR recovery point available
DR READINESS: PASS
```

## 3. DR Activation Criteria
Consider DR activation when:
- The primary region has a significant outage.
- Critical infrastructure is unavailable.
- Data corruption requires recovery.
- Primary-region recovery cannot meet business requirements.

Production activation should follow incident/change authorization.

## 4. Select a DR Recovery Point
```bash
aws backup list-recovery-points-by-backup-vault   --region us-west-2   --backup-vault-name banking-dr-dev-dr-vault   --output table
```

Select an appropriate recovery point in `COMPLETED` state.

## 5. Retrieve Restore Metadata
```bash
./scripts/restore-from-dr.sh
```

Review the metadata before initiating restoration.

## 6. Restore
Perform the approved AWS Backup restore in `us-west-2`.

## 7. Post-Restore Validation
Validate:
- Resource health
- Expected data
- IAM/security controls
- Network connectivity
- Application dependencies
- Monitoring

## 8. Measure Recovery
Record:
```text
Incident start:
DR declaration:
Restore start:
Restore completion:
Validation completion:
Service recovery:
```

`Actual RTO = Service Recovery Time - Incident Start Time`

Estimate observed RPO from the age of the latest usable recovery point.

## 9. Communications
Communicate incident severity, affected services, DR decision, selected recovery point, progress, validation results, RTO/RPO status and failback decision.

## 10. Closure
Close the DR event after recovery, data/application validation, monitoring restoration, stakeholder approval and evidence capture.
