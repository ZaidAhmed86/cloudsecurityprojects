# Project 1: IAM Cross-Account Access

## Overview

- This project implements cross-account IAM access between two AWS accounts — a Security Account and a Workload Account. 
- Instead of creating shared credentials, we use IAM role assumption via AWS STS, which is how production environments handle access across accounts.
- All infrastructure is managed with Terraform and tested end-to-end

---

## Account Structure
```
┌─────────────────────────────────────────────────────────────────┐
│                       AWS ENVIRONMENT                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────┐      ┌──────────────────────────┐ │
│  │   SECURITY ACCOUNT       │      │   WORKLOAD ACCOUNT       │ │
│  │   111111111111           │      │   222222222222           │ │
│  │                          │      │                          │ │
│  │  ┌────────────────────┐  │      │  ┌────────────────────┐  │ │
│  │  │  SecurityAdmin     │  │      │  │  SecurityAuditRole │  │ │
│  │  │  (IAM User)        │──┼──────┼─▶|  (read-only)      │  │ │
│  │  │                    │  │ STS  │  ├────────────────────┤  │ │
│  │  │  + AssumeRole      │  │Assume│  │  IncidentResponse  │  │ │
│  │  │    Permission      │  │ Role │  │  Role (limited     │  │ │
│  │  └────────────────────┘  │      │  │  write)            │  │ │
│  │                          │      │  ├────────────────────┤  │ │
│  │                          │      │  │  DeploymentRole    │  │ │
│  │                          │      │  │  (CI/CD scoped)    │  │ │
│  │                          │      │  └────────────────────┘  │ │
│  └──────────────────────────┘      └──────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## What Was Built

### Security Account (111111111111)
- **SecurityAdmin** — IAM user with no direct permissions to workload resources
- **AssumeRolesInWorkloadAccount** — Policy attached to SecurityAdmin allowing it to assume the 3 roles below

### Workload Account (222222222222)
- **SecurityAuditRole** — Read-only access for security reviews
- **IncidentResponseRole** — Read + limited write for active incident handling
- **DeploymentRole** — Scoped CI/CD permissions for deployments

| Role | Purpose | Key Permissions | MFA Required |
|------|---------|-----------------|--------------|
| SecurityAuditRole | Read-only security review | SecurityAudit, ViewOnlyAccess (AWS managed) | Yes |
| IncidentResponseRole | Active incident handling | EC2 describe + stop, revoke SG rules, CloudTrail read | Yes |
| DeploymentRole | CI/CD deployments | S3 read/write, Lambda update, ECR push/pull | No |

---

## How Role Assumption Works

Every role in the Workload Account has a trust policy — a rule that says who is allowed to assume it. Here is the flow:

1. SecurityAdmin calls AWS STS `AssumeRole` with the target role ARN, an ExternalId, and a live MFA code
2. AWS evaluates the trust policy on the target role — checking the source account, ExternalId, and MFA status
3. If all conditions pass, STS returns temporary credentials valid for up to 1 hour
4. SecurityAdmin uses those temporary credentials to act inside the Workload Account

The **ExternalId** prevents the confused deputy problem — where a third-party service tricks AWS into assuming a role on your behalf without your knowledge.

---

## Design Decisions

### Why role assumption instead of long-lived credentials?

| Long-Lived Access Keys | Role Assumption (this project) |
|------------------------|-------------------------------|
| Never expire — forgotten keys stay active | Temporary credentials expire in 1 hour |
| Can be leaked via code, logs, or emails | No secrets to leak — no static credentials |
| Hard to audit — no per-session tracking | Every assumption is logged in CloudTrail |
| MFA cannot be enforced | MFA can be required as a trust condition |
| Shared secrets between teams | Each session is isolated and traceable |

### Why ExternalId on every role?

- Without ExternalId, any account that knows your role ARN could potentially assume it. 
- ExternalId acts as a shared secret between the caller and the role — even if someone discovers the ARN, they cannot assume the role without the correct ExternalId.

### Why no MFA on DeploymentRole?

- CI/CD pipelines run automated and cannot interactively provide an MFA code. 
- The DeploymentRole compensates by being tightly scoped — it can only deploy to S3, Lambda, and ECR. 
- It cannot touch IAM, networking, or any other service.

---

## Scaling to 20 or 100 Accounts

The pattern used here scales cleanly. At larger scale:

- **AWS Organizations** groups accounts into OUs (Prod, Dev, Sandbox)
- **CloudFormation StackSets** deploys the same roles automatically to every account in an OU
- **Service Control Policies (SCPs)** prevent anyone from modifying or deleting those roles
- The **Security Account remains the single hub** — only its principals can assume roles anywhere

Adding a new account becomes a single StackSet deployment, not manual role creation.

---

## Security Considerations

### What happens if a role is over-privileged?

- A compromised over-privileged role can cause serious damage — deleting resources, exfiltrating data, creating backdoor users, or disabling logging. 
- A properly scoped role limits the blast radius to only what was explicitly granted. 
- Recovery from a scoped role compromise is straightforward. Recovery from an over-privileged one often is not.

### What happens if the Security Account is compromised?

The Security Account is the most sensitive account in this setup. If compromised, an attacker gains the ability to assume any role across all accounts. Mitigations:

- Enforce MFA on all human users in the Security Account
- Use SCPs to restrict what even the Security Account can do in workload accounts
- Enable GuardDuty and alert on role assumption from unexpected IPs or outside business hours
- Audit all trust policies regularly — no role should trust the Security Account root unnecessarily

---

## Monitoring and Detection

All role assumptions are logged automatically in AWS CloudTrail. The following events should trigger alerts:

| CloudTrail Event | Why It Matters |
|-----------------|----------------|
| AssumeRole from unexpected IP | Could indicate credential theft |
| AssumeRole failures | Repeated failures may indicate brute force |
| Role assumption outside business hours | Unusual access pattern worth investigating |
| Changes to trust policies | Someone may be widening access |
| Cross-account access from unapproved accounts | Unauthorised principal attempting access |

---

## Project Structure
```
01-iam-cross-account-access/
├── README.md
├── security-account/
│   ├── provider.tf
│   ├── iam_user.tf
│   └── iam_policy_assume.tf
└── workload-account/
    ├── provider.tf
    ├── iam_role_audit.tf
    ├── iam_role_incident.tf
    └── iam_role_deploy.tf
```
---

## Deliverables

- [x] Terraform code — `security-account/` and `workload-account/` directories
- [x] Trust policies with ExternalId and MFA conditions
- [x] Permission policies following least privilege for all 3 roles
- [x] End-to-end test confirming SecurityAdmin can assume SecurityAuditRole
- [x] Documentation covering design decisions and security considerations

> **Note:** The full architecture uses 4 accounts (Security, Workload, Logging, Dev/Test) 
> within AWS Organizations. This project implements the core pattern using 2 accounts — 
> the same trust and role assumption mechanics apply identically at any scale.

