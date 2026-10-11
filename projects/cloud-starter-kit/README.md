# Cloud Starter Kit

A reusable AWS hosting foundation for small businesses, built with Terraform, Docker, AWS Systems Manager, GitHub Actions, CloudWatch, and automated EBS backups.

## Status

**Version:** 0.1.0 MVP  
**Status:** Technical MVP validated  
**Validated workload:** Static web application  
**Next milestone:** First pilot customer

The current MVP has completed infrastructure, monitoring, backup, recovery, and automated deployment validation.

## What It Provides

```text
Terraform Infrastructure
        +
Docker / Nginx
        +
Caddy HTTPS
        +
AWS Systems Manager
        +
GitHub Actions + OIDC
        +
CloudWatch + SNS
        +
Automated EBS Backups
```

## Architecture

```text
Internet
   ↓
DNS
   ↓
Elastic IP
   ↓
AWS VPC / Public Subnet
   ↓
EC2
   ↓
Caddy :443
   ↓
Nginx 127.0.0.1:8080
   ↓
Static Application
```

Administration and deployment use AWS Systems Manager rather than public SSH.

## Automated Deployment

Application deployment follows:

```text
Feature branch
    ↓
Pull request validation
    ↓
Merge to main
    ↓
GitHub Actions
    ↓
OIDC authentication
    ↓
AWS Systems Manager
    ↓
Application deployment
    ↓
Local health check
    ↓
Public HTTPS checksum verification
```

The current validated deployment target is:

```text
projects/cloud-starter-kit/application/index.html
```

## Monitoring

Baseline monitoring uses Amazon CloudWatch and Amazon SNS.

Current alarms cover EC2 status-check failures and sustained high CPU utilization.

## Backups

AWS Data Lifecycle Manager creates daily encrypted EBS snapshots with seven-snapshot retention.

Snapshot-to-volume infrastructure recovery has been validated using an automatically generated backup.

## Documentation

Detailed documentation is available in:

- [`docs/Architecture.md`](docs/Architecture.md)
- [`docs/PRD.md`](docs/PRD.md)
- [`docs/PILOT-RUNBOOK.md`](docs/PILOT-RUNBOOK.md)

## Project Structure

```text
cloud-starter-kit/
├── application/
│   └── index.html
├── docs/
│   ├── Architecture.md
│   ├── PILOT-RUNBOOK.md
│   └── PRD.md
├── infrastructure/
│   ├── scripts/
│   └── terraform/
└── README.md
```

The GitHub deployment workflow is stored at repository level under:

```text
.github/workflows/deploy-cloud-starter-kit.yml
```

## Current Scope

The validated version 0.1.0 workload is intentionally simple: a static website hosted on a single EC2 application server.

Dynamic applications, APIs, databases, high availability, load balancing, auto scaling, Kubernetes, and multi-region disaster recovery are future capabilities rather than current MVP claims.

## Pilot

The next product milestone is onboarding a simple real-world pilot workload.

The pilot will validate not only the infrastructure but also the customer onboarding, deployment, monitoring, backup, recovery, support, and handover process.

## Demo

```text
https://demo.legatratechnologies.com
```

## Product Direction

```text
Cloud Starter Kit
      ↓
Managed Cloud
      ↓
Expanded workload support
      ↓
Cloud Platform
      ↓
Productized services
```
