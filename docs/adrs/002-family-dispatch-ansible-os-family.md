---
adr_number: "002"
status: accepted
created: 2026-09-28
supersedes: ""
superseded_by: ""
---

# ADR 002: Family-based dispatch via ansible_os_family, never ansible_distribution strings

## Context

The project targets 4 distros across 2 OS families (Debian: Ubuntu 24.04 + Debian 12;
RedHat: Rocky 9 + Amazon Linux 2023). Many tasks differ between families (package manager,
service names, firewall tool, SELinux vs AppArmor), but are identical within a family.

Two common approaches exist in multi-distro Ansible code: dispatching by distribution string
(`ansible_distribution == "Ubuntu"`) or by OS family (`ansible_os_family == "Debian"`).
The choice has cascading impact on every task file in all 15 roles.

## Alternatives Considered

- **Distribution string checks (`ansible_distribution ==`)** — fine-grained control per
  distro. Immediately familiar from documentation examples. But strings are not stable:
  Amazon Linux changed from `"Amazon"` (AL2) to `"Amazon Linux"` (AL2023); adding a new
  distro of the same family (e.g. AlmaLinux) requires editing every task file. Pattern is
  contagious — once one file uses it, others follow.

- **Family dispatch (`ansible_os_family`)** — one `Debian.yml` covers Ubuntu + Debian; one
  `RedHat.yml` covers Rocky + Amazon Linux + RHEL. Adding AlmaLinux 9 requires zero task
  changes. Family values are stable across distro versions.

- **Separate playbooks per distro** — one `baseline-ubuntu.yml`, one `baseline-rocky.yml`,
  etc. Eliminates conditionals but duplicates the entire role tree. Maintenance overhead
  grows quadratically with distros.

## Decision

**Family dispatch via `ansible_os_family` throughout all task files.**

Each role's `tasks/main.yml` dispatches with `ansible.builtin.include_tasks:
"{{ ansible_os_family }}.yml"`. Family task files (`Debian.yml`, `RedHat.yml`) contain
all family-specific work. Common tasks (rare) go in `main.yml` before the include.
No `ansible_distribution ==` checks anywhere in `tasks/` — enforced by `ansible-lint`
and auditable with a single `grep`.

## Consequences

- **Positive:** adding a new distro in the same family (AlmaLinux, Oracle Linux) requires
  zero task changes; family values are stable across minor OS versions; single grep confirms
  compliance across all roles.
- **Negative:** AL2023-specific quirks (e.g. `dnf` instead of `yum`, `amazon-linux-extras`
  removed) that differ from Rocky 9 must be handled with targeted conditionals inside
  `RedHat.yml` — `ansible_os_family` alone is not sufficient for every case.
- **Neutral / accepted trade-offs:** `group_vars/amazon_linux.yml` exists for AL2023-specific
  variable overrides that would otherwise require distribution checks inside task files.
