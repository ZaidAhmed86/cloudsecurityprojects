# High Findings — Remediation Roadmap

## Overview

60 real high findings across 7 unique issues. 
The majority (54 of 60) are regional duplicates of three missing detection services — the same
gap repeated across all 18 AWS regions.

---

## 1. Enable CloudTrail Across All Regions

**Findings:** 18 (one per region)
**Risk:** No API activity audit trail anywhere in the account. Every
action taken — by any user, role, or service — goes unrecorded.
Without CloudTrail, incident investigation is impossible.

**Remediation:**
- CloudTrail → Create trail → Apply to all regions
- Enable management events (read and write)
- Store logs in a dedicated S3 bucket with log file validation enabled
- Optionally integrate with CloudWatch Logs for real-time alerting

**Timeline:** Week 2 | **Effort:** ~30 minutes

---

## 2. Enable GuardDuty Across All Regions

**Findings:** 18 (one per region)
**Risk:** No active threat detection. Malicious activity —
compromised credentials, unusual API calls, reconnaissance — goes
completely undetected.

**Remediation:**
- GuardDuty → Enable in primary region → Enable across all regions
- Enable S3 Protection and Malware Protection
- Configure SNS alerts for High severity findings

**Timeline:** Week 2 | **Effort:** ~15 minutes

---

## 3. Enable Security Hub Across All Regions

**Findings:** 18 (one per region)
**Risk:** No centralized aggregation of security findings or compliance
framework visibility across the account.

**Remediation:**
- Security Hub → Enable in primary region → Enable across all regions
- Enable CIS AWS Foundations and AWS Foundational Security Best Practices
- Validate GuardDuty and IAM Access Analyzer integration

**Timeline:** Week 2-3 | **Effort:** ~20 minutes

---

## 4. Remove AdministratorAccess from IAM Roles

**Findings:** 3 roles

**Risk:** Excessive privileges increase blast radius if any of these
roles are assumed by a compromised service or user.

**Remediation:**
- IAM → Roles → identify roles with AdministratorAccess attached
- Review actual permissions required via Access Advisor
- Replace with scoped managed policies or a custom least-privilege policy
- Test role functionality after modification

**Timeline:** Week 3 | **Effort:** ~30-45 minutes

---

## 5. Eliminate Long-Lived IAM User Credentials

**Findings:** 2 users

**Risk:** Persistent access keys that never rotate are a standing
invitation for credential compromise. Every day they exist is another
day they could be leaked, phished, or stolen.

**Remediation:**
- IAM → Users → Security credentials → review active access keys
- Check last used date via Access Advisor
- Deactivate and delete keys that are unused or unnecessary
- Rotate any keys that must remain — enforce 90-day rotation policy
- Migrate to role-based temporary credentials where possible

**Timeline:** Week 3 | **Effort:** ~15 minutes

---

## 6. Add Confused Deputy Protection to IAM Service Roles

**Findings:** 1 role

**Risk:** Without `aws:SourceArn` or `aws:SourceAccount` conditions
in the trust policy, a service role can potentially be misused by
other AWS services acting on behalf of unintended principals.

**Remediation:**
- IAM → Roles → identify affected service role
- Edit trust policy to add condition block:
```json
"Condition": {
  "ArnLike": {
    "aws:SourceArn": "arn:aws:SERVICE:REGION:ACCOUNT:RESOURCE"
  },
  "StringEquals": {
    "aws:SourceAccount": "621715857254"
  }
}
```
- Validate service functionality after update

**Timeline:** Week 3 | **Effort:** ~20 minutes

---

## 7. Implement Region Restriction via SCP

**Findings:** 1

**Risk:** Without a Service Control Policy restricting allowed regions,
resources can be deployed in any of AWS's 30+ regions. An attacker with
valid credentials could spin up infrastructure in unused regions to
evade detection tools scoped to primary regions.

**Remediation:**
- AWS Organizations → Policies → Create SCP
- Define allowed regions using `aws:RequestedRegion` condition
- Attach SCP to account or root OU
- Test by attempting resource creation in a disallowed region

**Timeline:** Week 4 | **Effort:** ~30 minutes

---

## Summary

| Issue | Findings | Timeline | Effort |
|-------|----------|----------|--------|
| Enable CloudTrail | 18 | Week 2 | 30 min |
| Enable GuardDuty | 18 | Week 2 | 15 min |
| Enable Security Hub | 18 | Week 2-3 | 20 min |
| Remove AdministratorAccess from roles | 3 | Week 3 | 45 min |
| Eliminate long-lived credentials | 2 | Week 3 | 15 min |
| Confused deputy protection | 1 | Week 3 | 20 min |
| Region restriction SCP | 1 | Week 4 | 30 min |

---