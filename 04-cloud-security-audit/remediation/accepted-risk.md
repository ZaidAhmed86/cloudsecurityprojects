# Accepted Risks

## Context

This account is a personal test and learning environment with no
production workloads, no sensitive data, and no compliance obligations.
The findings below have been reviewed and intentionally accepted — they
represent governance, resilience, and enterprise-scale controls that
are not justified in the current context.

---

## Accepted Findings

| # | Finding | Count | Reason |
|---|---------|-------|--------|
| 1 | DRS not enabled | 18 | No business continuity requirements. No persistent workloads to recover. |
| 2 | AWS Backup vault not configured | 1 | Workloads are ephemeral. No data requiring retention or recovery. |
| 3 | Tag policies not enabled in AWS Organization | 1 | Single account. Governance overhead not justified at this scale. |
| 4 | SSM Incidents not configured | 1 | No production SLAs, no operational team, no formal response requirements. |
| 5 | AWS Premium Support not subscribed | 1 | No business-critical systems requiring guaranteed response times. |
| 6 | IAM SAML provider not configured | 1 | Single-user account. Federation adds no value here. |
| 7 | Region restriction SCP not implemented | 1 | Manually controlled account. CloudTrail and GuardDuty will mitigate once enabled. |
| 8 | Bedrock model invocation logging not enabled | 18 | Bedrock not in use in this account. |

---

## Production Equivalents

Each accepted finding has a clear production counterpart:

- **DRS and Backup** — mandatory for any account with persistent data or uptime requirements
- **Tag policies** — essential in multi-account environments for cost allocation and governance
- **SSM Incidents** — standard practice for teams with on-call rotations and SLA commitments
- **Premium Support** — required for production workloads with response time obligations
- **SAML federation** — best practice for any team-based or enterprise environment
- **Region SCPs** — critical control in multi-account setups to prevent shadow deployments
- **Bedrock logging** — required if AI workloads are introduced for audit and compliance

---

## Review Triggers

These accepted risks should be reassessed if any of the following occur:

- Production workloads are deployed
- Sensitive or regulated data is stored
- Additional IAM users are added
- Account migrates to a multi-account structure
- Compliance obligations are introduced

**Next scheduled review:** Quarterly
**Acceptance owner:** Zaid Ahmed

---