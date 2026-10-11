# Cloud Starter Kit Product Requirements Document

## Product Name

Cloud Starter Kit

## Version

0.1.0 MVP

## Status

Technical MVP Validated — Ready for Static-Web Pilot

## Product Objective

Provide small businesses with a repeatable AWS hosting environment that applies practical DevOps principles without requiring them to employ a full-time DevOps engineer.

The initial product is delivered as a managed implementation rather than as standalone Terraform source code or a self-service SaaS platform.

## Target Customer

The initial target customer is a small or medium-sized business with a straightforward web presence that needs reliable AWS hosting, HTTPS, monitoring, backups, and controlled application deployment.

The first pilot should use a simple static web workload.

## Current Validated Workload

Version 0.1.0 has been technically validated for:

- Static company websites
- Landing pages
- Static proof-of-concept websites

The current automated deployment process deploys a static `index.html` application through GitHub Actions and AWS Systems Manager.

## Core MVP Capabilities

The validated MVP provides:

- Terraform-managed AWS infrastructure
- Remote encrypted Terraform state
- Stable Elastic IP
- Docker application hosting
- Nginx web serving
- Caddy HTTPS termination
- Automatic TLS certificate management
- AWS Systems Manager administration
- No public SSH access
- GitHub pull-request validation
- GitHub Actions deployment
- GitHub OIDC authentication
- SHA256 deployment verification
- Local application health validation
- Public HTTPS deployment verification
- CloudWatch infrastructure monitoring
- SNS alert notification
- Automated encrypted EBS snapshots
- Seven-snapshot retention
- Validated snapshot-to-volume recovery
- Pilot operations runbook

## Deployment Requirements

Application changes must follow:

```text
Feature branch
    ↓
Pull request
    ↓
Validation
    ↓
Merge to main
    ↓
Automated deployment
    ↓
Local health check
    ↓
Public HTTPS verification
```

Pull requests must not deploy to the live application host.

AWS authentication from GitHub must use OIDC rather than permanent AWS access keys.

## Security Requirements

The application host must:

- Allow public inbound traffic only for HTTP and HTTPS
- Avoid exposing SSH
- Use AWS Systems Manager for administration
- Require IMDSv2
- Use encrypted EBS storage
- Use IAM roles rather than embedded AWS credentials
- Terminate public traffic over HTTPS

## Monitoring Requirements

The MVP must detect:

- EC2 status-check failures
- Sustained high CPU utilization

Alerts must be delivered through Amazon SNS to a confirmed recipient.

## Backup Requirements

The application host must receive an automated encrypted EBS snapshot every 24 hours.

The lifecycle policy must retain seven snapshots.

## Recovery Requirement

The MVP must demonstrate the ability to create an encrypted EBS volume from an automatically generated backup snapshot.

Full disaster-recovery restoration is not part of version 0.1.0 acceptance criteria.

## MVP Acceptance Status

The following capabilities have been demonstrated successfully:

```text
Terraform infrastructure            COMPLETE
Remote state                        COMPLETE
Stable public IP                    COMPLETE
HTTPS                               COMPLETE
Systems Manager                     COMPLETE
GitHub CI                           COMPLETE
GitHub OIDC                         COMPLETE
Monitoring                          COMPLETE
SNS alerts                          COMPLETE
Automated backups                   COMPLETE
Snapshot-to-volume recovery         COMPLETE
Automated static-app deployment     COMPLETE
Deployment health validation        COMPLETE
Public HTTPS verification           COMPLETE
Pilot operations runbook            COMPLETE
```

## Out of Scope for Version 0.1.0

Version 0.1.0 does not claim validated support for:

- Dynamic application runtimes
- APIs
- Databases
- Kubernetes
- High availability
- Load balancers
- Auto scaling
- Multi-region deployment
- Zero-downtime deployment
- Full automated disaster recovery
- Formal compliance certification
- Enterprise observability

These capabilities may be evaluated after pilot feedback.

## Success Criteria

Version 0.1.0 is successful when:

1. The technical MVP operates reliably.
2. A simple pilot workload can be onboarded.
3. Deployment, monitoring, backup, and recovery procedures are repeatable.
4. Operational feedback can be collected from a real pilot.
5. The feedback provides evidence for the next managed-cloud product iteration.

## Next Stage

The next stage is customer validation rather than additional infrastructure scope.

```text
Technical MVP
     ↓
Static-web pilot customer
     ↓
Operational feedback
     ↓
Managed Cloud refinement
     ↓
Broader workload support
```
