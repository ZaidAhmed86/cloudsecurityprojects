# Pipeline Design

## Overview

- Security checks that happen after deployment are expensive — in time, money, and reputation. 
- This pipeline embeds five independent security scans directly
into the development workflow so issues are caught at the cheapest possible
point: before code is merged.
- Every scan runs automatically on push and pull request. No manual steps,
no opt-in required, no way to accidentally skip it.

---

## Pipeline Architecture
```
Developer pushes code
        │
        ▼
GitHub Actions triggered
        │
        ├── Secret Scanning (Gitleaks)
        ├── SAST (Semgrep)
        ├── Dependency Scanning (npm audit)
        ├── IaC Scanning (Checkov)
        └── Container Scanning (Trivy)
                │
                ▼
        All pass → merge allowed
        Any fail → merge blocked
```

All five workflows run in parallel. A failure in any one of them blocks
the pull request from merging until the finding is resolved or a documented
exception is approved.

---

## Workflow Triggers

Each workflow uses path filters to only trigger on relevant file changes.
This keeps the pipeline fast and avoids unnecessary scans.

| Workflow | Triggers On |
|----------|-------------|
| Secret Scanning | Any change in `03-cicd-security-pipeline/` |
| SAST | Any change in `03-cicd-security-pipeline/` |
| Dependency Scanning | Any change in `03-cicd-security-pipeline/` + weekly schedule |
| IaC Scanning | Changes in `03-cicd-security-pipeline/` or `02-vpc-infrastructure-as-code/` |
| Container Scanning | Changes in `03-cicd-security-pipeline/app/` only |

- The IaC scan deliberately reaches into Project 2 — Checkov validates the
Terraform files whenever infrastructure code changes, regardless of which
project triggered the push. 
- This mirrors how security pipelines work in real monorepos.
- The dependency scan runs on a weekly schedule in addition to push and PR
triggers. 
- Vulnerabilities are disclosed continuously — a package that was
safe last month may have a critical CVE today. 
- The scheduled scan catches this without requiring a code change to trigger it.

---

## Security Stages

### Stage 1 — Secret Scanning
**Tool:** Gitleaks
**Runs on:** Every push and PR

- Gitleaks scans the entire Git commit history, not just the latest change.
- A secret committed three months ago and later deleted still exists in Git
history and is still a real credential exposure. 
- Full history scanning ensures nothing is missed.

If a secret is found the workflow fails immediately and posts the finding
as a PR annotation showing the exact file, line, and secret type detected.

### Stage 2 — Static Analysis
**Tool:** Semgrep
**Runs on:** Every push and PR

Semgrep analyses source code without executing it, looking for insecure
patterns across three rule sets:

- `p/security-audit` — broad security issues across languages
- `p/secrets` — hardcoded credentials inside source code
- `p/nodejs` — Node.js specific patterns including unsafe eval(), prototype
  pollution, SQL injection, and insecure deserialization

Semgrep runs in seconds and posts findings directly on the relevant lines
in the PR diff, giving developers immediate context about what the issue
is and how to fix it.

### Stage 3 — Dependency Scanning
**Tool:** npm audit
**Runs on:** Every push, PR, and weekly schedule

- npm audit checks every installed package against the npm advisory database.
- It distinguishes between vulnerabilities in direct dependencies (packages
you explicitly chose) and transitive dependencies (packages your packages
depend on).

The pipeline fails on critical severity findings only. Lower severity
findings are surfaced as warnings — visible in the workflow output but
not blocking. This threshold is a deliberate decision documented in
security-decisions.md.

### Stage 4 — Infrastructure as Code Scanning
**Tool:** Checkov
**Runs on:** Changes to Terraform files in any project

Checkov validates Terraform files against 1,000+ built-in security policies
before any infrastructure change reaches AWS. Common findings include:

- Security groups open to 0.0.0.0/0
- S3 buckets without encryption or public access blocks
- Missing VPC flow logs
- IAM policies with wildcard permissions
- Unencrypted RDS instances

Catching these in the pipeline costs nothing to fix. The same finding
after deployment requires a change window, testing, and potential downtime.

### Stage 5 — Container Scanning
**Tool:** Trivy
**Runs on:** Changes to app files

Trivy builds the Docker image from the Dockerfile and scans it for
vulnerabilities at two levels:

- **OS packages** — vulnerabilities in the Alpine Linux base image packages
- **Application dependencies** — vulnerabilities in packages installed
  inside the container via npm

The pipeline only fails on critical findings that have a fix available.
Findings without a fix are reported but do not block — there is no action
a developer can take on an unfixed vulnerability, so blocking on them
creates noise without enabling resolution.

---

## Monorepo Path Filtering

Because all projects share one repository, each workflow uses GitHub Actions
path filters to scope its triggers precisely:
```yaml
on:
  push:
    paths:
      - '03-cicd-security-pipeline/**'
```

- This means a documentation change in Project 2 does not trigger Project 3
scans, and a workflow file update does not trigger a container rebuild.
- Each scan only runs when the files it cares about actually change, keeping
pipeline minutes low and feedback fast.

---

## Developer Experience

Security pipelines fail when developers route around them. This pipeline
is designed to be useful rather than obstructive:

- **Fast** — all five scans run in parallel, total time under 5 minutes
- **Actionable** — findings include file, line number, and remediation guidance
- **Proportionate** — only critical findings block, lower severity findings warn
- **Transparent** — every decision about what blocks and what warns is
  documented in security-decisions.md

---