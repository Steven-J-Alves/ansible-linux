# ansible-linux — OS-level baseline

Ansible project that provisions a professional, multi-distro OS-level baseline for application servers. Covers SSH hardening, firewall, kernel tuning, users, audit, observability, and more — across Ubuntu 24.04, Debian 12, Rocky 9, and Amazon Linux 2023.

## Requirements

- Docker (everything else runs inside the control node container)

## Layout

See `CONVENTIONS.md` for the pattern this project follows.

## Quickstart

```bash
# Build the control node image (once, or after version bumps)
make build

# Lint
make lint

# Syntax-check the main playbook
make syntax-check

# Run Molecule for a specific role + distro scenario
make molecule-test role=baseline_common scenario=ubuntu2404

# Drop into an interactive shell inside the control node
make shell
```

All Molecule test containers (Geerlingguy images) are spawned by the control node via the
Docker socket — no VPS, no cloud required.

## Rollback

Every role in `roles/` has a documented rollback procedure in `docs/rollback-procedures.md`. Consult before applying to production.
