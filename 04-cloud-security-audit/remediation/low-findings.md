# Low Findings — Remediation Plan

## Overview

44 real low findings across 9 unique checks. Low findings represent
optional governance, visibility, and operational maturity controls.
None present immediate security risk.

---

## Strategy

Fix the items that are quick wins or foundational habits. Accept the
rest as backlog with documented rationale.

---

## Fix Opportunistically

### 1. Enable IAM Access Analyzer

**Findings:** 18 (one per region)

**Risk:** No continuous analysis of IAM policies to detect overly
permissive access or unintended external access to resources.

**Remediation:**
- IAM → Access Analyzer → Create analyzer
- Scope to current account or organization
- Review any findings surfaced on first run

**Effort:** ~5 minutes

---

### 2. Enable Full CloudTrail Read/Write Logging

**Findings:** 18 (one per region)

**Risk:** Even once CloudTrail is enabled, logging only write events
leaves a visibility gap — read events like `GetObject` or
`AssumeRole` go unrecorded.

**Remediation:**
Addressed automatically when enabling CloudTrail in high-findings
remediation — ensure both read and write management events are
selected during trail creation

**Effort:** No additional effort — covered by CloudTrail enablement

---

### 3. Fix IAM Password Policy — Lowercase Requirement

**Findings:** 1

**Risk:** Minor complexity gap in the password policy.

**Remediation:**
- IAM → Account settings → Edit password policy
- Enable lowercase letter requirement
- Addressed alongside the medium findings password policy fix

**Effort:** Included in password policy update — no additional effort

---

### 4. Review IAM Users With No Policies Attached

**Findings:** 2

**Risk:** Unused or misconfigured identities add unnecessary noise
and potential attack surface.

**Remediation:**
- IAM → Users → identify users with no attached policies
- Determine if the users are still needed
- Delete unused users or attach appropriate least-privilege policies

**Effort:** ~10 minutes

---

## Accepted as Backlog

| Finding | Reason |
|---------|--------|
| AWSSupportAccess role not attached | No business-critical systems requiring AWS support escalation |
| IAM SAML provider not configured | Single-user account — federation not required |
| Tag policies not enabled | Single account — tagging governance not justified at this scale |
| AWS Premium Support not subscribed | No production SLAs or uptime requirements |

Full rationale in `remediation/accepted-risks.md`.

---