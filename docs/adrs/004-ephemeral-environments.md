---
adr_number: "004"
status: accepted
created: 2026-09-28
supersedes: ""
superseded_by: ""
---

# ADR 004: Ephemeral environment model (dev=Docker, staging=EC2 on-demand, production=real)

## Context

The project needs three logical environments: dev (fast iteration), staging (real-VM
validation before production), and production (openclaw VPS or client EC2). The project
currently has one real production VPS (openclaw). Maintaining persistent dev/staging
environments has an ongoing cost (EC2 hours) even when idle.

The inventory structure (`inventories/{dev,staging,production}/`) was already decided as
part of the project standard. This ADR records the runtime model behind each environment.

## Alternatives Considered

- **Persistent dev + staging VMs** — always-on EC2 or VMs for dev and staging. Predictable
  IP addresses, no provisioning delay. But idle cost accumulates even when no work is in
  progress; one production VPS does not justify two always-on staging machines.

- **Docker-only (no staging tier)** — collapse dev and staging into Docker/Molecule; apply
  directly to production with `--check --diff` as the only gate. Simpler, but Docker
  containers share the host kernel — they cannot validate kernel parameters, SELinux
  enforcing, or real systemd service management. The gap between Docker and a real VM is
  exactly where the riskiest roles (SSH, firewall, MAC) can fail.

- **Ephemeral model (adopted)** — dev is Docker/Molecule (disposable, seconds), staging is
  an on-demand EC2 (`t3.micro` / `t4g.small`) spun up for the test run and destroyed
  immediately after, production is the real persistent VPS/EC2. Zero idle cost for
  dev/staging.

## Decision

**Ephemeral model: dev=Docker (Molecule), staging=on-demand EC2, production=real.**

`inventories/staging/hosts.yml` is versioned in the repo but its IP is updated each time
a new EC2 is spawned (via Terraform sibling or manual). Staging EC2 is destroyed after
validation — it is never left running. The three lock-out-risk roles (`baseline_ssh`,
`baseline_firewall`, `baseline_mac`) require a staging EC2 run before production apply.

## Consequences

- **Positive:** zero idle infra cost; staging environment accurately represents production
  (real kernel, real systemd, real SELinux/AppArmor); ephemeral model forces the playbook
  to be fully idempotent from a cold start.
- **Negative:** staging EC2 provisioning adds a few minutes to the workflow for high-risk
  roles; `inventories/staging/hosts.yml` requires an IP update each time.
- **Neutral / accepted trade-offs:** Terraform for staging EC2 provisioning is implicit in
  the model but not designed in this project — it can be a sibling `terraform/` folder or
  done via the AWS console for now.
