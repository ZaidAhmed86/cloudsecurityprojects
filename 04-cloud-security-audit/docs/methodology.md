# Audit Methodology

## Scope & Objectives

| Item | Detail |
|------|--------|
| Account Type | Personal test/learning environment |
| Scan Date | 09 February 2026 |
| Regions Covered | All 18 active AWS regions |
| Total Checks | 572 |
| Tool | Prowler v5.19.0 |
| Output Formats | JSON (ASFF) and HTML |

**Objectives:**
- Identify security configuration gaps across AWS services
- Distinguish real vulnerabilities from false positives
- Prioritize findings based on business context and risk
- Produce an actionable remediation roadmap

---

## What Was Scanned

- **IAM** — users, roles, policies, credentials, MFA
- **Logging** — CloudTrail, CloudWatch, S3 access logs
- **Networking** — security groups, NACLs, VPCs
- **Data Protection** — EBS, RDS, S3 encryption, KMS
- **Monitoring** — GuardDuty, Security Hub, Inspector2

---

## Triage Framework

Raw Prowler output is not a risk assessment. Every finding was evaluated
against the actual account context before being classified as a real
issue, false positive, or accepted risk.

**Account context applied to all findings:**
- Single user, personal test environment
- No sensitive or production data
- No compliance obligations
- Ephemeral, non-critical workloads

| Severity | Total | Real Issues | False Positives |
|----------|-------|-------------|-----------------|
| Critical | 14 | 2 | 12 |
| High | 129 | 60 | 69 |
| Medium | 156 | 101 | 55 |
| Low | 46 | 44 | 2 |

---

## Key Triage Decisions

- **Critical (14 → 2 real):**
12 findings were false positives — policies correctly not granting admin
access, flagged as CRITICAL due to how Prowler labels that check
category. The 2 real issues both relate to `AdminIAMUser` having
unrestricted `AdministratorAccess`.
- **High (129 → 60 real):**
Real issues centre on detection infrastructure — CloudTrail, GuardDuty,
and Security Hub all disabled across 18 regions. Genuine gaps regardless
of account type.
- **Medium (156 → 101 real):**
Primarily monitoring and governance gaps. Important for production
environments but lower priority for a personal test account with no
sensitive data.
- **Low (46 → 44 real):**
Optional governance and enterprise features. Accepted as backlog with
documented rationale.

---

## Limitations

- Configuration-based checks only — no application security, penetration
  testing, or real-time threat intelligence
- Regional findings multiplied across 18 regions inflate total counts —
  unique check types are significantly fewer than total finding counts
- Prowler severity labels reflect industry scanning standards, not
  business context — triage is required before acting on any finding

---

## Ongoing Monitoring Plan

| Frequency | Activity |
|-----------|----------|
| Weekly | Run Prowler scan |
| Monthly | Review findings and track remediation progress |
| Quarterly | Comprehensive re-prioritization |

**Escalation triggers:**
- Any new Critical finding
- Unauthorized resource creation detected
- Credential compromise indicators

---