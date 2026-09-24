# Disaster Recovery Strategy

## Objective
Provide a repeatable mechanism to protect AWS resources and recover critical data following infrastructure or regional failure.

## Implemented Strategy
```text
Backup and Restore
+ Cross-Region Copy
+ Recovery Validation
+ Monitoring
+ Operational Automation
```

## Tag-Based Protection
Resources are onboarded using:
```text
Backup = true
```

## Monitoring
AWS Backup job state changes are monitored with EventBridge and routed to SNS.

## Readiness
```bash
./scripts/dr-readiness-check.sh
```

## Strategy Options
- Backup and Restore — longer recovery objectives.
- Pilot Light — core DR components remain available.
- Warm Standby — reduced-capacity DR environment runs continuously.
- Multi-Site — workloads operate across regions with greater cost/complexity.

## Project Boundary
This lab demonstrates the cross-region backup/recovery foundation; it does not claim to implement a complete active/active banking platform.
