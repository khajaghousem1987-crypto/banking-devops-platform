# Disaster Recovery Runbook

## 1. Purpose

This runbook defines the operational procedure for responding to a disaster affecting the primary AWS region.

The Project 5 implementation uses:

- Primary Region: `us-east-1`
- DR Region: `us-west-2`
- AWS Backup
- Cross-region recovery point copies
- EBS recovery testing
- EventBridge monitoring
- SNS notifications
- Terraform
- Operational validation scripts

## 2. Recovery Objectives

| Objective | Target |
|---|---:|
| RTO | 30 minutes |
| RPO | 15 minutes |
| Primary Region | us-east-1 |
| DR Region | us-west-2 |

These values are project recovery targets. They must not be interpreted as achieved production SLAs until validated through timed end-to-end recovery testing.

## 3. DR Architecture

```text
Primary Region - us-east-1
        |
        | AWS Backup
        v
Primary Backup Vault
        |
        | Cross-Region Copy
        v
DR Region - us-west-2
        |
        v
DR Backup Vault
        |
        v
Recovery Point
        |
        v
Restore Procedure