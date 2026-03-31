# Cloud Security Portfolio

A collection of production-grade cloud security projects built to demonstrate
real-world thinking, not just tool familiarity. Each project mirrors how cloud
security is actually practiced — with documented trade-offs, clean infrastructure
code, and clear reasoning behind every decision.

---

## Projects

| # | Project | Domain | Status |
|---|---------|--------|--------|
| 1 | [IAM Cross-Account Access](./01-iam-cross-account-access/) | Identity & Access Management | ✅ Complete |
| 2 | [VPC Infrastructure as Code](./02-vpc-infrastructure-as-code/) | Network Security | ✅ Complete |
| 3 | [CI/CD Security Pipeline](./03-cicd-security-pipeline/). | DevSecOps | ✅ Complete |
| 4 | [Cloud Security Audit](04-cloud-security-audit/). | Compliance & Audit | ✅ Complete |
| 5 | Centralized Logging | Visibility & Logging | 🔜 Coming Soon |
| 6 | Break-Glass Access | Operations & Recovery | 🔜 Coming Soon |
| 7 | Secrets Management | Credential Hygiene | 🔜 Coming Soon |
| 8 | Threat Modeling | Risk Analysis | 🔜 Coming Soon |

---

## What Each Project Demonstrates

These are not tutorials or guided labs. Each project is built from scratch,
deployed to a real AWS environment, and documented with the reasoning behind
every design decision — including the trade-offs.

**Project 1 — IAM Cross-Account Access**
Implements a least-privilege cross-account role assumption pattern across
multiple AWS accounts. Covers multi-account architecture, role trust policies,
and permission boundaries.

**Project 2 — VPC Infrastructure as Code**
Builds a production-grade three-tier VPC using Terraform with security as a
first-class concern. Covers network segmentation, defence in depth, security
group chaining, VPC flow logs, and VPC endpoints. Full infrastructure is
version-controlled and reproducible with a single command.

**Project 3 — CI/CD Security Pipeline**
Integrates automated security scanning directly into a GitHub Actions pipeline, treating security as a pipeline gate rather than an afterthought. Covers SAST, secrets detection, container image scanning, dependency auditing, and IaC scanning. Every pull request is blocked from merging if any high or critical findings are detected.

**Project 4 — AWS Cloud Security Audit**
Conducts a structured cloud security audit of an AWS environment using Prowler against CIS and AWS Foundational Security benchmarks. Covers audit methodology, findings triage by severity, compliance mapping, and a remediation plan with accepted-risk documentation. Produces both an executive summary and a detailed technical findings report.

---

## Repository Structure
```
cloud-security-portfolio/
├── README.md                          # This file
├── 01-iam-cross-account-access/
│   ├── README.md                      # Project documentation
│   ├── terraform/                     # Infrastructure code
│   └── docs/                          # Additional documentation
├── 02-vpc-infrastructure-as-code/
│   ├── README.md
│   ├── terraform/
│   └── docs/
├── 03-cicd-security-pipeline/
│   ├── README.md
│   ├── .github/workflows/             # Pipeline configurations
│   └── policies/                      # Security policies
├── 04-cloud-security-audit/
│   ├── README.md
│   ├── reports/                       # Sample audit outputs
│   └── remediation/                   # Remediation guides
```

---

## Stack

- **Cloud:** AWS
- **IaC:** Terraform >= 1.0
- **CLI:** AWS CLI v2
- **Version Control:** Git

---

## Prerequisites

To deploy any project yourself:

- An AWS account (free tier works for most projects)
- Terraform >= 1.0 installed
- AWS CLI configured with credentials
- Git

---

## A Note on Approach

Each project is built to answer the question a security engineer would actually
ask — not just "does it work?" but "is it secure, is it auditable, and would
I trust this in production?"

Documentation in each project explains not just what was built but why specific
choices were made and what would change in a real enterprise environment.

