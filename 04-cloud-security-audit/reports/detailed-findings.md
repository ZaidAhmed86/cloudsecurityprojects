# Detailed Findings

## Critical (2 Real Issues, 12 False Positives)

### Real Issues

**IAM user `AdminIAMUser` has `AdministratorAccess` directly attached.**

- Grants unrestricted permissions (`*:*`) across all AWS services and resources
- Compromise of this identity results in full account takeover capability
- Both critical findings relate to the same root cause — the same user, the same policy

### False Positives (12)
Prowler flagged policies correctly not granting admin access as CRITICAL
because of how it labels that check category. These controls are working
as intended.

- Attached AWS-managed IAM policies do not allow `*:*` ✅
- Custom IAM policies do not allow privilege escalation ✅
- IAM users enforced with MFA ✅

---

## High (60 Real Issues, 69 False Positives)

### Real Issues

**Detection Infrastructure (54 findings — 18 regions × 3 services)**

| Check | Regions Affected | Risk |
|-------|-----------------|------|
| CloudTrail not enabled | 18 | No API activity audit trail |
| GuardDuty not enabled | 18 | No threat detection |
| Security Hub not enabled | 18 | No compliance aggregation |

These are genuine gaps regardless of account type. Without CloudTrail
there is no record of what has happened in the account. Without
GuardDuty there is no active threat detection.

**Identity & Access Control (6 findings)**

| Finding | Count | Risk |
|---------|-------|------|
| IAM roles with AdministratorAccess | 3 | Excessive blast radius |
| Long-lived IAM user credentials | 2 | Persistent credential exposure |
| IAM service role missing confused deputy protection | 1 | Cross-service privilege misuse |

**Governance (1 finding)**

| Finding | Risk |
|---------|------|
| No SCP restricting resource deployment to approved regions | Attackers may deploy resources in unused regions to evade detection |

### False Positives (69)
Controls verified working correctly:

- EMR Block Public Access enabled ✅
- EventBridge bus not public ✅
- Root user not recently used ✅
- Custom IAM policies do not allow privilege escalation ✅
- VPC endpoint services restricted to trusted principals ✅

---

## Medium (101 Real Issues, 55 False Positives)

### Real Issues

**CloudWatch Monitoring Gaps (13 findings)**

No metric filters or alarms configured for critical control plane events:
- Root account usage
- Unauthorized API calls
- IAM policy changes
- Console sign-ins without MFA
- Security group, NACL, route table changes
- CloudTrail and KMS key modifications

**Configuration & Governance (88 findings)**

| Finding | Regions | Priority |
|---------|---------|----------|
| AWS Config not enabled | 18 | Fix — Month 1 |
| Inspector2 not enabled | 18 | Fix — Month 1 |
| IAM password policy weaknesses | 1 | Fix — Month 1 |
| DRS not configured | 18 | Accepted — non-production |
| Bedrock invocation logging disabled | 18 | Accepted — service not in use |
| AWS Organization not configured | 1 | Accepted — single account |
| SSM Incidents not configured | 1 | Accepted — no production SLAs |

### False Positives (55)
Controls verified working correctly:

- CloudWatch does not allow cross-account sharing ✅
- No users have AWSCloudShellFullAccess ✅
- Custom IAM policies do not allow `cloudtrail:*` or `kms:*` wildcard ✅
- IAM access keys properly rotated ✅

---

## Low (44 Real Issues, 2 False Positives)

Low findings represent optional governance and enterprise maturity
controls. None present immediate security risk.

| Finding | Count | Decision |
|---------|-------|----------|
| IAM Access Analyzer not enabled | 18 | Fix opportunistically |
| CloudTrail not logging full read/write events | 18 | Fix with CloudTrail enablement |
| No AWS Backup vault | 1 | Accepted — no data to protect |
| IAM password policy missing lowercase requirement | 1 | Fix with password policy update |
| IAM users with no policies attached | 2 | Review and clean up |
| AWSSupportAccess role not attached | 1 | Accepted — test account |
| No IAM SAML provider | 1 | Accepted — single user |
| Tag policies not enabled | 1 | Accepted — single account |
| AWS Premium Support not subscribed | 1 | Accepted — test account |

---

## Summary

| Severity | Total | Real | False Positive | Fix | Accept |
|----------|-------|------|----------------|-----|--------|
| Critical | 14 | 2 | 12 | 2 | 0 |
| High | 129 | 60 | 69 | 60 | 0 |
| Medium | 156 | 101 | 55 | 16 | 85 |
| Low | 46 | 44 | 2 | 21 | 23 |

---