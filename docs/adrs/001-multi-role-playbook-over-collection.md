---
adr_number: "001"
status: accepted
created: 2026-09-28
supersedes: ""
superseded_by: ""
---

# ADR 001: Multi-role + orchestrating playbook over monolithic role or Collection

## Context

The project must deliver an OS-level baseline for heterogeneous fleets (4 distros, 3 environments).
The 15 Linux domains to configure (SSH, firewall, kernel, users, etc.) are largely independent and
carry different lock-out risk levels. A structure decision must be made before writing any code,
because migrating between patterns after roles exist is expensive.

Three structural options exist in Ansible: a single monolithic role, a multi-role library with an
orchestrating playbook, or a formal Ansible Collection published to Galaxy.

## Alternatives Considered

- **Single monolithic role** — one role does everything. Simple to apply (`roles: [baseline]`),
  but `defaults/main.yml` becomes unmanageable as 15 domains grow. Molecule tests always run
  everything together — no isolation. Non-reusable outside the baseline context.

- **Multi-role + orchestrating playbook (Option B)** — 15 thin `baseline_*` roles, each covering
  one domain. Composed by `playbooks/baseline.yml`. Each role is independently testable via
  Molecule and reusable in future projects without the full baseline.

- **Ansible Collection (`namespace.baseline`)** — roles packaged as a Galaxy collection.
  Enables versioned releases and distribution to other teams. Adds namespace, version, and
  publishing overhead with no immediate benefit (not publishing to Galaxy now).

## Decision

**Multi-role + orchestrating playbook (Option B).**

The deciding factors: each role must be independently testable (Molecule per distro), each role
maps to one Linux learning domain (pedagogical goal), and the project grows incrementally —
roles are added one at a time with full test coverage before the next starts. Migrating Option B
to a Collection later is trivial (restructure + `galaxy.yml`); migrating a monolith is not.

## Consequences

- **Positive:** each role is isolated, tested independently, and reusable outside the baseline;
  Molecule scenarios target one domain at a time (fast feedback); clear mapping to the 17 Linux
  learning domains in `prompt.md`.
- **Negative:** 15 separate directories means more boilerplate at scaffold time; `ansible-galaxy
  collection` commands are not needed now, which may feel like missing tooling.
- **Neutral / accepted trade-offs:** Collection migration is intentionally deferred — the
  `namespace.collection` overhead is overhead without benefit until distribution to other teams
  is actually needed.
