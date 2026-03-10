# Security Decisions

- Every pipeline decision involves a tradeoff between security coverage and developer experience. 
- Too strict and developers route around the process.
- Too lenient and real vulnerabilities reach production. 
- This document explains where each line was drawn and why.

---

## Secrets — Always Block, No Exceptions

- Gitleaks is configured to fail immediately on any secret found anywhere in Git history. 
- There is no threshold, no severity level, no exception process.
- A committed secret is a compromised credential regardless of whether it was later deleted. Git history is permanent and widely cloned. 
- The only correct response is to rotate the credential immediately and treat it as exposed.

This is the one area where developer convenience is not a factor. The cost
of a leaked AWS key or API token is too high to allow any flexibility.

---

## SAST — Block on High and Critical Only

Semgrep runs three rule sets but only blocks on high and critical severity
findings. Low and medium findings are surfaced as warnings in the PR.

- **Tradeoff:** Some real vulnerabilities at lower severity will not block
  deployment. This is accepted to keep the false positive rate manageable.
- **Reasoning:** A pipeline that generates 20 warnings on every PR trains
  developers to ignore warnings entirely. Starting with high-confidence,
  high-severity rules builds trust in the tooling before expanding coverage.
- **Future state:** As the team tunes rules and the false positive rate drops
  below 10%, medium severity findings would be promoted to blocking.

---

## Dependency Scanning — Critical CVEs Only, Weekly Schedule

npm audit is configured with `--audit-level=critical` so only critical
severity CVEs fail the pipeline. The scan also runs on a weekly schedule
independent of code changes.

- **Tradeoff:** High severity vulnerabilities in dependencies will not block
  deployment. Teams should review the weekly scan output and remediate
  high severity findings on a tracked schedule even if they don't block.
- **Reasoning:** Many high severity CVEs in dependencies have no practical
  exploit path in a given application's context. Blocking on all high
  findings would generate significant noise and dependency churn. Critical
  CVEs with exploit available represent an unacceptable risk regardless
  of context.
- **Weekly schedule:** Vulnerabilities are disclosed continuously. A package
  that passes today may have a critical CVE tomorrow. The scheduled scan
  catches this without requiring a developer to push code first.

---

## IaC Scanning — Block on All Policy Violations

Checkov is configured with `soft_fail: false`, meaning any policy violation
fails the pipeline. There is no severity threshold — all findings block.

- **Tradeoff:** New findings may appear as Checkov's policy library updates,
  blocking previously passing PRs unexpectedly.
- **Reasoning:** Infrastructure misconfigurations are categorically different
  from application vulnerabilities. A misconfigured security group or public
  S3 bucket affects the entire environment, not just one application. The
  blast radius justifies a zero-tolerance approach.
- **Practical note:** When Checkov flags existing infrastructure code the
  correct response is to fix the misconfiguration, not to lower the threshold.
  Each finding is an opportunity to improve the infrastructure security posture.

---

## Container Scanning — Critical with Fix Available Only

Trivy is configured to block on critical severity findings that have a fix
available. Two deliberate scoping decisions here:

- **`severity: CRITICAL` only** — same reasoning as dependency scanning.
  Critical findings represent unacceptable risk regardless of context.
- **`ignore-unfixed: true`** — findings without an available fix are reported
  but do not block. Blocking on unfixable vulnerabilities creates noise
  without enabling any action. When a fix becomes available the scan
  automatically starts blocking and prompts remediation.

- **Tradeoff:** High severity OS vulnerabilities in the base image will not
  block. The mitigation is keeping the base image version pinned and updated
  regularly — `node:20-alpine` should be updated to the latest patch release
  on a regular schedule.

---

## Base Image Pinning

The Dockerfile uses `node:20-alpine` rather than `node:latest` or just `node`.

- **`latest` risk:** The latest tag changes without notice and can silently
  introduce new vulnerabilities or breaking changes between builds.
- **Pinning to a major version** (`20`) is a balance — it receives security
  patches automatically within the major version while avoiding unexpected
  major version upgrades.
- **Production consideration:** In a high-security environment, images would
  be pinned to a specific digest (`node:20-alpine@sha256:...`) for fully
  reproducible builds. This is not implemented here to avoid the operational
  overhead of manually updating digest pins.

---

## Non-Root Container User

The Dockerfile runs the application as the `node` user rather than root.

- If an attacker exploits a vulnerability in the application, they gain the privileges of the process running it. 
- Running as root inside a container means a successful exploit gives the attacker root access to the container
filesystem, the ability to install tools, and potential paths to container
escape. 
- Running as a non-root user limits what an attacker can do even
after a successful exploit.

Trivy flags containers running as root as a misconfiguration. This decision
ensures the container scan passes on this check by default.

---

## Parallel Execution

All five workflows run in parallel rather than sequentially.


- **Tradeoff:** A secret scan failure does not prevent the container scan
  from running — all five run simultaneously regardless of each other's
  results.
- **Reasoning:** Parallel execution keeps total pipeline time under 5 minutes.
  Sequential execution would mean waiting for each scan to complete before
  starting the next, pushing total time to 15-20 minutes. Slow pipelines
  get bypassed. The tradeoff of running unnecessary scans on a failing
  branch is worth the speed benefit.


---