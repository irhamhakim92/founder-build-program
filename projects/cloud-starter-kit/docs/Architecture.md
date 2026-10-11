# Cloud Starter Kit Architecture

## Overview

The Cloud Starter Kit is a reusable AWS hosting environment designed for a simple static web workload.

The current validated MVP uses a single EC2 application host with Docker, Nginx, Caddy, AWS Systems Manager, CloudWatch monitoring, automated EBS backups, and GitHub Actions deployment.

## Architecture

```text
Internet
   |
   v
DNS
   |
   v
Elastic IP
   |
   v
AWS VPC
   |
   v
Public Subnet
   |
   v
EC2 Application Host
   |
   +-- Caddy
   |     |
   |     +-- HTTP → HTTPS redirect
   |     +-- TLS certificate management
   |     +-- Reverse proxy
   |             |
   |             v
   |       127.0.0.1:8080
   |             |
   |             v
   +------- Nginx Docker Container
                 |
                 v
          Static Application
```

## AWS Infrastructure

The Terraform configuration provisions:

- VPC
- Internet Gateway
- Public subnet
- Public route table
- Security group
- Ubuntu EC2 instance
- Elastic IP
- IAM role and instance profile for Systems Manager
- CloudWatch alarms
- SNS alert topic
- Data Lifecycle Manager backup policy
- GitHub Actions OIDC roles

The EC2 root EBS volume uses encrypted `gp3` storage.

Instance Metadata Service Version 2 is required.

## Network Access

The application host security group permits public inbound traffic only on:

```text
TCP 80   HTTP
TCP 443  HTTPS
```

SSH port 22 is not exposed.

Administrative access and automated remote commands use AWS Systems Manager.

## Application Runtime

The current MVP application is static HTML served by an Nginx Docker container.

Nginx is bound to:

```text
127.0.0.1:8080
```

It is not exposed directly to the Internet.

Caddy is the public-facing web server and reverse proxy.

## HTTPS

Caddy listens on ports 80 and 443.

It provides:

- HTTP-to-HTTPS redirection
- Automatic TLS certificate management
- HTTPS termination
- Reverse proxying to Nginx

The validated demo endpoint is:

```text
https://demo.legatratechnologies.com
```

## Deployment Architecture

```text
Developer
   |
   v
Feature Branch
   |
   v
Pull Request
   |
   +-- Application validation
   |
   v
Merge to main
   |
   v
GitHub Actions
   |
   +-- GitHub OIDC
   |
   v
AWS Deployment IAM Role
   |
   v
Systems Manager Run Command
   |
   v
EC2 Application Host
   |
   +-- Download exact Git commit
   +-- Verify SHA256
   +-- Replace application
   +-- Local health check
   |
   v
Public HTTPS checksum verification
```

Pull requests do not deploy application changes.

Deployment occurs after changes reach `main`.

No permanent AWS credentials are required by the deployment workflow.

## Monitoring

Amazon CloudWatch currently provides baseline infrastructure monitoring.

The MVP includes:

- EC2 status-check alarm
- High CPU utilization alarm
- SNS alert notifications

Application-level observability is outside the current MVP scope.

## Backup and Recovery

AWS Data Lifecycle Manager creates automated encrypted EBS snapshots of the application host.

Current policy:

```text
Frequency: Daily
Retention: 7 snapshots
Target: EC2 application host
Encryption: Enabled
```

Recovery validation has successfully demonstrated:

```text
DLM snapshot
    ↓
Create EBS volume
    ↓
Encrypted gp3 volume
    ↓
Volume available
```

This validates snapshot-to-volume infrastructure recovery.

A complete EC2 rebuild, filesystem validation, DNS failover, and formal disaster-recovery test remain future hardening work.

## Terraform State

Terraform state is stored remotely in Amazon S3.

The backend uses:

- Server-side encryption
- S3 state storage
- Native Terraform state locking

Terraform state should not be stored in Git.

## Current Validated Scope

The current MVP has been validated for a static website workload.

Dynamic web applications, APIs, databases, customer-specific Docker images, load balancing, auto scaling, private application subnets, and multi-region recovery require additional engineering before being offered as validated capabilities.

## Future Evolution

The intended product evolution is:

```text
Cloud Starter Kit
        ↓
Managed Cloud Service
        ↓
Expanded application workloads
        ↓
Reusable Cloud Platform
        ↓
Productized SaaS capabilities
```
