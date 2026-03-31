# Executive Summary

## Scan Overview

| Item | Detail |
|------|--------|
| Scan Date | 09 February 2026 |
| Account Type | Personal test/learning environment |
| Tool | Prowler v5.19.0 |
| Checks Executed | 572 |
| Findings Returned | 345 |
| Pass Rate | 40% |

---

## Findings Summary

| Severity | Total | Real Issues | False Positives |
|----------|-------|-------------|-----------------|
| Critical | 14 | 2 | 12 |
| High | 129 | 60 | 69 |
| Medium | 156 | 101 | 55 |
| Low | 46 | 44 | 2 |

---

## Critical Finding

**IAM user `AdminIAMUser` has `AdministratorAccess` directly attached.**

- This grants unrestricted permissions (`*:*`) across all AWS services and
resources. 
- In a production environment this would represent a severe risk —
compromise of this identity results in full account takeover capability.
- The 12 other CRITICAL flags were false positives — policies correctly
not granting admin access, flagged because of how Prowler labels that
check category.

---

## Risk Context

- This is a personal test account with no production workloads, no sensitive
data, and no compliance obligations. 
- The critical finding represents a configuration that does not reflect best practice, but operational risk
in this specific context is low.
- In a production environment containing sensitive data or active
infrastructure, this configuration would be an immediate critical
control failure.

---

## Recommended Actions

- **Week 1 — Critical:**
Remove `AdministratorAccess` from `AdminIAMUser` and replace with a
scoped least-privilege role. 15-minute fix.
- **Week 2-3 — High:**
Enable CloudTrail, GuardDuty, and Security Hub across all 18 regions.
These are genuine detection gaps regardless of account type — no audit
trail means no visibility into what has happened or is happening.
- **Month 1-2 — Medium:**
Enable AWS Config and Inspector2. Strengthen IAM password policy.
Eliminate long-lived access keys.
- **Backlog — Low/Accepted:**
DRS, Backup vaults, AWS Organizations features, and Support plans
deferred with documented rationale. See `remediation/accepted-risks.md`.

---