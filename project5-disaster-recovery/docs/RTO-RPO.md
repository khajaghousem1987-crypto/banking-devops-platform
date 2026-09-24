# Recovery Time Objective and Recovery Point Objective

## Targets
- RTO: **30 minutes**
- RPO: **15 minutes**

These are design targets.

## Demonstrated
The project demonstrated EBS backup, primary recovery points, cross-region copies, DR recovery points, repeated scheduled recovery points and DR readiness validation.

## Limitation
A timed end-to-end restore is required before claiming the 30-minute RTO was achieved. A daily backup schedule alone does not guarantee a 15-minute RPO.

## Measuring RTO
```text
T0 incident/test start
T1 DR declaration
T2 restore initiated
T3 restore completed
T4 validation completed
T5 service available

Actual RTO = T5 - T0
```

## Measuring RPO
Compare the incident/data-loss time with the timestamp of the latest usable recovery point.

## Production Improvement
Stricter RPOs may require continuous replication, database-native replication, S3 replication or other workload-specific protection mechanisms.
