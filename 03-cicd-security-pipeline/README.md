# Project 3: CI/CD Pipeline With Security Built In

A GitHub Actions security pipeline that automatically scans code, dependencies,
infrastructure, and container images on every push and pull request. Security
checks run automatically — no manual intervention required.

---

## Pipeline Overview

Every push or pull request touching this project triggers five independent
security scans in parallel:

| Workflow | Tool | What It Scans | Blocks On |
|----------|------|---------------|-----------|
| Secret Scanning | Gitleaks | Entire Git history | Any secret found |
| SAST | Semgrep | Application source code | High/Critical findings |
| Dependency Scanning | npm audit | Third party packages | Critical CVEs |
| IaC Scanning | Checkov | Terraform files | Policy violations |
| Container Scanning | Trivy | Docker image | Critical CVEs with fix available |

---

## Project Structure
```
03-cicd-security-pipeline/
├── README.md
├── app/
│   ├── package.json        # Node.js dependencies
│   ├── index.js            # Express REST API
│   └── Dockerfile          # Container definition
└── docs/
    ├── pipeline-design.md  # How the pipeline works
    └── security-decisions.md # Block vs warn decisions
```

Workflows live at the repo root under `.github/workflows/` and use path
filters to only trigger on relevant file changes.

---

## Note on Workflow Location

- GitHub Actions requires workflows to live at `.github/workflows/` at the
repository root. 
- The workflow files for this project are located there
rather than inside this project folder. 
- This is standard practice in a
monorepo where multiple projects share one repository.

The path filters in each workflow ensure they only trigger on changes
relevant to this project — pushing changes to other projects will not
fire these scans.

---

## Security Tools

- **Gitleaks** scans the entire Git history for secrets — AWS keys, API tokens, passwords, and private keys. 
Catches secrets that were committed and later deleted but still exist in history.

- **Semgrep** performs static analysis on source code without executing it. 
Runs three rule sets — general security audit, secret detection, and Node.js specific vulnerability patterns.

- **npm audit** checks installed dependencies against the npm advisory database for known CVEs. 
Also runs on a weekly schedule to catch newly disclosed vulnerabilities in existing dependencies.

- **Checkov** scans Terraform infrastructure code against 1,000+ built-insecurity policies. 
Catches misconfigurations before they reach AWS — open security groups, unencrypted storage, missing flow logs, and more.

- **Trivy** builds the Docker image and scans it for OS and application vulnerabilities. 
Only fails the pipeline on critical findings that have a fix available.

---

## Prerequisites

- GitHub repository with Actions enabled
- Semgrep account for dashboard reporting (free at semgrep.dev)
- `SEMGREP_APP_TOKEN` added to GitHub repository secrets

---

## Stack

- **Runtime:** Node.js 20
- **Framework:** Express 4.18.2
- **Container:** Docker (node:20-alpine)
- **CI:** GitHub Actions
- **Secret Scanning:** Gitleaks
- **SAST:** Semgrep
- **Dependency Scanning:** npm audit
- **IaC Scanning:** Checkov
- **Container Scanning:** Trivy

---