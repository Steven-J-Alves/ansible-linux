---
adr_number: "003"
status: accepted
created: 2026-09-28
supersedes: ""
superseded_by: ""
---

# ADR 003: Molecule with Docker driver (Geerlingguy images) as primary test framework

## Context

Each of the 15 baseline roles must be testable against all 4 declared distros before
reaching production. Tests must be fast enough to run in a tight feedback loop during
development and must not require cloud credentials or persistent VMs on a developer machine.

The validation pipeline also includes Lynis (hardening score) post-converge and
`ansible-playbook --check --diff` against a real staging EC2 for the three lock-out-risk
roles. This ADR covers the local/fast tier only (Molecule).

## Alternatives Considered

- **Molecule + Docker driver (Geerlingguy images)** — runs containers with functional
  systemd (not just PID 1 init). Geerlingguy maintains images for all four target distros.
  Fast (seconds per scenario), no cloud credentials, no idle cost. Covers 95% of role logic.

- **Molecule + Vagrant driver** — full VMs locally; accurate kernel and systemd behavior.
  Slower (minutes per scenario), requires a local hypervisor (VirtualBox/libvirt), heavy on
  RAM. Justified only when the test needs real kernel features (seccomp, SELinux enforcing)
  that Docker cannot provide.

- **Molecule + cloud driver (EC2/DigitalOcean)** — real VMs in the cloud; accurate but
  incurs cost per run, requires cloud credentials, and is slow (VM provisioning overhead).
  Suitable for CI (phase 2) but not for the local dev loop.

- **No automated testing (manual only)** — not acceptable. A role applied to production
  without automated idempotency verification is a footgun.

## Decision

**Molecule + Docker driver with Geerlingguy images as the primary and required test tier.**

Every role must have one Molecule scenario per declared distro. Scenarios use:
- `geerlingguy/docker-ubuntu2404-ansible`
- `geerlingguy/docker-debian12-ansible`
- `geerlingguy/docker-rockylinux9-ansible`
- `geerlingguy/docker-amazonlinux2023-ansible`

The Docker tier covers idempotency, converge correctness, and verify assertions. Real-VM
testing (ephemeral EC2) is reserved for the three lock-out-risk roles and is complementary,
not a replacement.

## Consequences

- **Positive:** scenario runs in seconds; no cloud credentials needed for the dev loop;
  Geerlingguy images provide functional systemd, which is required by roles that manage
  services, journald, and timers.
- **Negative:** Docker containers share the host kernel — roles that configure kernel
  parameters (sysctl, module blacklisting) or enforce MAC policies (SELinux enforcing,
  AppArmor in enforce mode) cannot be fully validated in Docker. These require the
  staging EC2 tier.
- **Neutral / accepted trade-offs:** Docker Hub pull limits (100 pulls/6h unauthenticated)
  are not an issue for local development but will require authentication when CI is added
  in phase 2.
