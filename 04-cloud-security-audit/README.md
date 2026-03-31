# Project 4: Cloud Security Audit with Prowler

- A full-cycle AWS security audit using Prowler — covering scan execution,
finding triage, risk-based prioritization, and a remediation roadmap.
- The focus is not on running the tool but on interpreting the results
with professional judgment.

---

## The Core Idea

- Running a security scanner is the easy part. 
- The real skill is knowing which findings represent genuine risk in your specific context, which are
noise, and which require a business decision rather than a technical fix.

---

## Scan Results

| Severity | Total Findings | Real Issues | False Positives |
|----------|---------------|-------------|-----------------|
| Critical | 14 | 2 | 12 |
| High | 129 | 60 | 69 |
| Medium | 156 | 101 | 55 |
| Low | 46 | 44 | 2 |

**572 checks run. 40% passing.**

---

## Signal vs Noise

Prowler severity labels reflect scanning standards, not business context.
Triage requires reclassifying findings based on your environment.

- **Example false positive:**
Prowler flagged "Attached IAM policy does not allow `*:*` administrative
privileges" as CRITICAL. This is the control working correctly — the
policy is doing exactly what it should. Zero risk.

- **Real critical issue:**
IAM user `AdminIAMUser` has `AdministratorAccess` attached — full
unrestricted access to the entire account. 15-minute fix, high impact.

- **Real high issues:**
All detection infrastructure was missing across all 18 regions —
CloudTrail, GuardDuty, and Security Hub all disabled. These are genuine
gaps regardless of account type.

- **Why medium and low were deferred:**
Medium findings (CloudWatch alarms, backup, DR) are important in
production but lower priority for a personal test account with no
sensitive data or compliance requirements. Low findings (support plans,
SAML, tag policies) only provide value at enterprise scale.

---

## Compliance Posture

| Framework | Current | Post-Remediation |
|-----------|---------|------------------|
| CIS AWS Foundations v5.0 | 40% | ~70% |
| NIST Cybersecurity Framework | 40% | ~65% |

See `docs/compliance-mapping.md` for full framework analysis.

---

## Remediation Roadmap

| Timeline | Action | Impact |
|----------|--------|--------|
| Week 1 | Remove AdministratorAccess from AdminIAMUser | Eliminates unrestricted admin access |
| Week 2-3 | Enable CloudTrail, GuardDuty, Security Hub across all regions | Full audit trail + threat detection |
| Month 1-2 | Enable AWS Config, Inspector2, strengthen IAM password policy | Configuration management + vuln scanning |
| Backlog | DRS, Backup, Organizations features, Support plans | Accepted — non-production, no data to protect |

---

## Project Structure
```
04-cloud-security-audit/
├── README.md
├── reports/
│   ├── sample-prowler-output.json     # Raw Prowler output
│   ├── executive-summary.md           # High-level findings
│   └── detailed-findings.md           # Technical details
├── remediation/
│   ├── critical-findings.md           # Immediate action items
│   ├── high-findings.md               # Sprint-level items
│   ├── medium-findings.md             # Quarter-level items
│   └── accepted-risks.md              # Documented exceptions
├── scripts/
│   ├── run-prowler.sh                 # Prowler execution script
│   └── parse-results.py               # Results parsing helper
└── docs/
    ├── methodology.md                 # How the audit was conducted
    └── compliance-mapping.md          # Maps to CIS, SOC2, etc.
```

---

## Lessons Learned

- Raw scanner output is not a risk assessment — triage and context are what turn findings into actionable intelligence
- ~40% of findings were noise — a junior analyst could spend days fixing things that aren't broken
- Severity labels are a starting point, not a verdict
- Detection gaps are often more dangerous than misconfiguration gaps — no CloudTrail means no audit trail, which turns every other finding into an unknown
- Accepted risk is not ignored risk — documenting why a finding doesn't apply is professional practice, not 

---