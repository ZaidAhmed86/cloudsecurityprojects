# Medium Findings — Remediation Plan

## Overview

101 real medium findings across 33 unique checks. 
The majority are regional duplicates of the same gaps across 18 regions. 
Medium findings represent monitoring, governance, and operational maturity gaps — none
are actively exploitable vulnerabilities.

---

## Strategy

- Fix foundational monitoring controls opportunistically
- Accept resilience and enterprise governance items as backlog
- Revisit if account evolves toward production use

---

## Fix Opportunistically

### 1. Configure CloudWatch Metric Filters and Alarms

**Findings:** 13
**Risk:** No alerting on critical control plane events. Suspicious
activity — root usage, unauthorized API calls, IAM changes — happens
silently.

**Priority events to monitor:**
- Root account usage
- Unauthorized API calls
- IAM policy changes
- Console sign-ins without MFA
- Security group and NACL changes
- CloudTrail configuration changes
- KMS key deletion or disabling

**Remediation:**
- Create a CloudWatch Logs metric filter per event type
- Create an SNS topic for alert delivery
- Attach a CloudWatch alarm to each metric filter
- Validate by triggering a test event

**Effort:** ~30 minutes

---

### 2. Enable AWS Config

**Findings:** 18 (one per region)
**Risk:** No configuration drift tracking. Changes to resources go
unrecorded and cannot be correlated with security events.

**Remediation:**
- AWS Config → Enable configuration recorder in primary region
- Record all supported resource types
- Deliver snapshots to a dedicated S3 bucket

**Effort:** ~15 minutes

---

### 3. Enable Inspector2

**Findings:** 18 (one per region)
**Risk:** No automated vulnerability scanning for EC2, ECR images,
or Lambda functions.

**Remediation:**
- Amazon Inspector → Enable Inspector2
- Activate scanning for EC2, ECR, and Lambda
- Review findings dashboard after first scan

**Effort:** ~10 minutes

---

### 4. Strengthen IAM Password Policy

**Findings:** 6
**Risk:** Weak password policy increases credential compromise risk
for console users.

**Current gaps:**
- Minimum length below 14 characters
- Missing complexity requirements (uppercase, number, symbol)
- No expiration or reuse prevention enforced

**Remediation:**
- IAM → Account settings → Edit password policy
- Set minimum length to 14 characters
- Enable uppercase, number, and symbol requirements
- Set expiration to 90 days, prevent reuse of last 24 passwords

**Effort:** ~5 minutes

---

## Accepted as Backlog

| Finding | Reason |
|---------|--------|
| DRS not enabled (18 regions) | No production workloads or data to recover |
| Bedrock invocation logging disabled (18 regions) | Service not in use |
| AWS Organization not configured | Single account — overhead not justified |
| SSM Incidents not configured | No production SLAs or response team |
| VPCs not present in multiple regions | Single region deployment by design |
| AWS account contact details incomplete | Personal account — not applicable |
| AWS AI opt-out policy not configured | No AI workloads |

Full rationale for each accepted item in `remediation/accepted-risks.md`.

---