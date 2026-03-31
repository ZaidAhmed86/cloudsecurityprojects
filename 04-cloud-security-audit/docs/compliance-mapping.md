# Compliance Mapping

## Overview

Audit findings mapped to two industry frameworks most relevant to this
environment. Full compliance is not required for a personal test account
— this mapping demonstrates awareness of how findings align to recognized
security standards.

---

## CIS AWS Foundations Benchmark v5.0

| Section | Control | Status | Notes |
|---------|---------|--------|-------|
| 1.1 | Avoid root account usage | PASS | No active root keys |
| 1.2 | MFA on root account | PASS | MFA enabled |
| 1.5 | IAM least privilege | FAIL | AdminIAMUser has full admin — Critical finding |
| 1.7 | Remove unused credentials | FAIL | Long-lived keys in use — High finding |
| 1.12 | Enforce MFA for IAM users | PARTIAL | Not enforced via policy |
| 1.16 | Enable IAM Access Analyzer | FAIL | Not enabled — Low finding |
| 2.1 | Enable CloudTrail | FAIL | Not enabled in any region — High finding |
| 2.4 | CloudTrail logs encrypted | FAIL | Dependent on CloudTrail enablement |
| 2.6 | CloudTrail multi-region | FAIL | Not enabled — High finding |
| 3.1 | CloudWatch metric filters | FAIL | No alarms configured — Medium finding |
| 4.1 | Security groups restrict traffic | PASS | Configured appropriately |
| 4.3 | Default VPC usage | PASS | Present but unused — accepted |

**CIS Coverage: ~40% passing | Projected post-remediation: ~70%**

---

## NIST Cybersecurity Framework 2.0

| Function | Status | Key Gap |
|----------|--------|---------|
| Govern (GV) | PARTIAL | Single-account governance in place; no org-level controls |
| Identify (ID) | PARTIAL | No AWS Config or asset inventory |
| Protect (PR) | FAIL | Admin user violates access control principles |
| Detect (DE) | FAIL | CloudTrail, GuardDuty, and CloudWatch all disabled |
| Respond (RS) | PARTIAL | No formal response plan; manual response sufficient for test account |
| Recover (RC) | ACCEPT | No production workloads; DRS deferred |

**NIST CSF Coverage: ~40% passing | Projected post-remediation: ~65%**

---

## Compliance Gap Summary

| Framework | Current | Post-Remediation | Primary Gap |
|-----------|---------|------------------|-------------|
| CIS AWS v5.0 | 40% | ~70% | Logging and detection |
| NIST CSF 2.0 | 40% | ~65% | Detect function entirely absent |

The majority of compliance gaps stem from a single root cause — detection
and logging infrastructure is completely absent. Enabling CloudTrail,
GuardDuty, and Security Hub in Week 2-3 addresses the largest share of
failing controls across both frameworks simultaneously.

---

## Framework Applicability

**Implemented here:**
- CIS AWS Foundations — industry standard AWS security baseline
- NIST CSF — broad cybersecurity framework applicable to any environment

**Deferred:**
- SOC 2 — relevant if scaling to a service provider
- NIST 800-53 — governs federal contractors
- PCI DSS — not processing payments
- HIPAA — no healthcare data

---