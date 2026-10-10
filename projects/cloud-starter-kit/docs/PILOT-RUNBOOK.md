# Cloud Starter Kit — Pilot Operations Runbook

## 1. Purpose

The Cloud Starter Kit provides a repeatable AWS environment for small businesses that need to host a website, web application, API, or internal tool without maintaining a full-time DevOps team.

The MVP provides:

- Infrastructure provisioned with Terraform
- HTTPS with automatic TLS certificate management
- Docker-based application hosting
- GitHub-based CI validation
- Automated application deployment
- AWS Systems Manager administration without SSH
- CloudWatch infrastructure monitoring
- SNS alert notifications
- Automated encrypted EBS backups
- Tested snapshot-to-volume recovery
- Remote Terraform state

This runbook documents how a pilot environment is onboarded, deployed, monitored, backed up, recovered, and handed over.

---

## 2. MVP Scope

The Cloud Starter Kit MVP is intended for a simple single-server workload.

Typical examples:

- Company website
- Landing page
- Small web application
- Lightweight API
- Internal business tool
- Proof-of-concept application

The current MVP is not designed for:

- High-availability multi-instance workloads
- Kubernetes
- Large-scale databases
- Multi-region disaster recovery
- Zero-downtime enterprise deployment
- Formal cybersecurity compliance certification
- Complex production platforms with many services

These capabilities may be added in later service tiers.

---

## 3. Architecture Overview

The pilot architecture uses AWS in a single region.

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
   |     +-- HTTPS / TLS
   |     |
   |     v
   +-- Nginx Docker Container
         |
         v
   Application Content
```

Supporting services:

```text
GitHub
   |
   +-- Pull Request Validation
   |
   +-- GitHub Actions
         |
         +-- OIDC temporary AWS credentials
         |
         v
      AWS Systems Manager
         |
         v
      EC2 Application Host


EC2
 |
 +-- CloudWatch alarms
 |       |
 |       v
 |      SNS
 |       |
 |       v
 |   Alert recipient
 |
 +-- EBS root volume
         |
         v
   Data Lifecycle Manager
         |
         v
   Daily encrypted snapshots
```

---

## 4. Customer Information Required

Before onboarding a pilot customer, collect:

### Business

- Company name
- Primary technical contact
- Primary business contact
- Alert notification email
- Preferred AWS region
- Expected application type

### Domain

- Domain name
- DNS provider
- Access to create or modify DNS records

### Application

- Application repository
- Application type
- Required runtime
- Required environment variables
- External API dependencies
- Expected ports
- Health-check endpoint

### AWS

Determine whether the deployment will use:

- Customer-owned AWS account, or
- A temporary pilot environment managed by Legatra Technologies

Never request or store a customer's root AWS credentials.

---

## 5. Infrastructure Provisioning

Infrastructure is managed through Terraform.

Terraform is responsible for the AWS infrastructure lifecycle.

Before any Terraform change:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

Review the Terraform plan carefully.

A normal change should clearly state the expected number of resources to:

```text
add
change
destroy
```

Do not apply unexpected destructive changes.

Production infrastructure changes should follow:

```text
feature branch
    ↓
pull request
    ↓
CI validation
    ↓
review
    ↓
merge
    ↓
terraform apply
```

Direct infrastructure development on `main` should be avoided.

---

## 6. Application Deployment

Application deployment does not require SSH.

The deployment path is:

```text
Application change
      ↓
Git feature branch
      ↓
Pull request
      ↓
Application validation
      ↓
Merge to main
      ↓
GitHub Actions
      ↓
GitHub OIDC
      ↓
AWS deployment IAM role
      ↓
Systems Manager Run Command
      ↓
EC2 application host
      ↓
Application update
      ↓
Local health check
      ↓
Public HTTPS verification
```

Pull requests validate application changes but do not deploy them.

Deployment is allowed only after the change reaches the `main` branch.

The deployment workflow:

1. Authenticates to AWS using GitHub OIDC.
2. Finds the running EC2 instance tagged as the application host.
3. Calculates the repository application's SHA256 checksum.
4. Creates an SSM deployment command.
5. Downloads the exact application version associated with the Git commit.
6. Verifies the downloaded SHA256 checksum.
7. Preserves the previous application file temporarily.
8. Replaces the application file.
9. Runs a local health check through Nginx.
10. Rolls back the file if the local health check fails.
11. Verifies the application through the public HTTPS endpoint.
12. Confirms that the public file checksum matches the Git repository version.

No permanent AWS access keys are stored in GitHub for this deployment path.

---

## 7. HTTPS

Public traffic is terminated by Caddy.

Caddy:

- Listens on ports 80 and 443
- Redirects HTTP traffic to HTTPS
- Manages TLS certificates
- Reverse-proxies requests to the application

The application container is bound locally to:

```text
127.0.0.1:8080
```

It is not intended to be accessed directly from the public Internet.

The public demo endpoint is:

```text
https://demo.legatratechnologies.com
```

A successful production check should return an HTTP success response over HTTPS.

---

## 8. Monitoring

The MVP uses Amazon CloudWatch.

Current baseline alarms include:

### EC2 Status Check

Detects infrastructure or operating-system status-check failures.

### High CPU

Detects sustained high CPU utilization.

Alarm events are sent to an Amazon SNS topic.

The configured alert recipient must confirm the SNS email subscription before alerts can be received.

During customer onboarding, verify:

- SNS subscription is confirmed
- CloudWatch alarms exist
- Alarm state is visible
- Contact information is current

Monitoring in this MVP focuses on infrastructure health.

Application-level observability can be added in a later managed-service tier.

---

## 9. Backups

The application EC2 root volume is protected by AWS Data Lifecycle Manager.

Backup policy:

```text
Frequency: Daily
Retention: 7 snapshots
Storage: EBS snapshots
Encryption: Enabled
Target: Application host
```

DLM-created snapshots are managed by the lifecycle policy.

Do not manually delete active DLM-managed snapshots unless the reason is understood and documented.

Check available backups with AWS CLI by querying snapshots associated with the DLM policy.

A healthy backup should report:

```text
State: completed
Encrypted: True
```

---

## 10. Recovery Procedure

The MVP recovery procedure has been validated from an actual automated DLM snapshot.

Recovery validation demonstrated:

```text
Automated DLM snapshot
        ↓
Completed encrypted snapshot
        ↓
Create new EBS volume
        ↓
Encrypted gp3 volume
        ↓
Volume state: available
```

### Important limitation

The current MVP test proves **snapshot-to-volume infrastructure recovery**.

It does not yet constitute a full disaster-recovery exercise involving:

- Booting a replacement EC2 instance
- Mounting the restored filesystem
- Validating every application file
- Repointing production DNS
- Measuring formal recovery time objectives

These are future production-hardening activities.

### Recovery Steps

1. Identify the newest completed DLM snapshot.
2. Confirm the snapshot is encrypted.
3. Identify the Availability Zone where recovery will occur.
4. Create a new `gp3` EBS volume from the snapshot.
5. Wait until the volume becomes `available`.
6. Verify:
   - Snapshot ID
   - Encryption
   - Volume size
   - Volume type
   - Availability Zone
7. Attach or use the restored volume as required by the recovery scenario.
8. Validate application data before returning traffic to the recovered environment.

Temporary recovery-test resources should be removed after validation to avoid unnecessary AWS charges.

---

## 11. Systems Manager Administration

AWS Systems Manager is used instead of exposing SSH administration.

Benefits include:

- No SSH key distribution
- Reduced administrative attack surface
- Central AWS authorization
- Remote command execution
- Integration with automated deployment

The EC2 instance must remain registered as a Systems Manager managed node.

If deployment fails, check:

1. EC2 instance state
2. SSM agent state
3. Instance IAM profile
4. Systems Manager managed-node status
5. GitHub deployment workflow logs
6. SSM command invocation output

---

## 12. Incident Response Basics

### Website unavailable

Check:

```text
DNS
↓
Elastic IP
↓
EC2 running state
↓
EC2 status checks
↓
Caddy
↓
Nginx container
↓
Application content
```

### Deployment failed

Review the GitHub Actions deployment run.

Determine which stage failed:

```text
OIDC authentication
SSM target discovery
SSM SendCommand
Remote deployment
Local health check
Public HTTPS verification
```

Do not manually overwrite application files until the failed automation is understood.

### High CPU alert

Check:

- Current CPU utilization
- Recent deployments
- Running processes
- Docker container state
- Unexpected traffic

### EC2 status-check failure

Check the EC2 instance and AWS status information.

If recovery is required, use the latest valid backup according to the recovery procedure.

---

## 13. Pilot Onboarding Checklist

Before declaring a pilot live:

- [ ] Customer contacts recorded
- [ ] AWS region confirmed
- [ ] Workload requirements reviewed
- [ ] Domain confirmed
- [ ] DNS configured
- [ ] Terraform infrastructure applied
- [ ] EC2 application host healthy
- [ ] Systems Manager connectivity confirmed
- [ ] Docker running
- [ ] Nginx application container running
- [ ] Caddy running
- [ ] HTTPS certificate active
- [ ] Public HTTPS endpoint tested
- [ ] GitHub OIDC configured
- [ ] Deployment IAM role deployed
- [ ] Pull request validation tested
- [ ] Automated deployment tested
- [ ] Public deployment checksum verified
- [ ] CloudWatch alarms active
- [ ] SNS alert subscription confirmed
- [ ] DLM backup policy enabled
- [ ] Automated snapshot confirmed
- [ ] Recovery procedure validated
- [ ] Customer limitations explained

---

## 14. Handover Checklist

At pilot handover, provide:

- Production URL
- Architecture summary
- Deployment process
- Alert recipient details
- Backup policy
- Recovery procedure
- Known limitations
- Support contact
- Change-management process
- AWS responsibility boundaries

Never hand over:

- Root AWS credentials
- Personal AWS credentials
- Long-lived deployment secrets
- Private authentication material through insecure channels

---

## 15. MVP Acceptance Criteria

The Cloud Starter Kit MVP is considered technically ready when all of the following have been demonstrated:

- [x] AWS infrastructure provisioned using Terraform
- [x] Remote Terraform state configured
- [x] Public IP remains stable
- [x] HTTPS works
- [x] Application runs through Docker and Nginx
- [x] Systems Manager administration works
- [x] Terraform CI validation works
- [x] GitHub OIDC authentication works
- [x] CloudWatch monitoring works
- [x] SNS alerts are configured
- [x] Automated encrypted backups exist
- [x] Snapshot-to-volume recovery has been validated
- [x] Automated deployment from `main` works
- [x] Deployment performs local health validation
- [x] Deployment verifies public HTTPS content
- [x] Pilot operations procedure is documented

---

## 16. Current MVP Status

The Cloud Starter Kit has completed its technical MVP validation.

The next stage is:

```text
Pilot customer
      ↓
Real workload onboarding
      ↓
Operational feedback
      ↓
Managed Cloud service refinement
      ↓
Productized platform
```

The first pilot should remain intentionally simple so the operational model can be validated before introducing higher-complexity workloads.
