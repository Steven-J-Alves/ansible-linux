# Brainstorm — Ansible Linux Baseline

Maturation session to define a professional Ansible project for an OS-level Linux baseline, focused on hardening + tuning + diagnostics + observability for production application servers. Doubles as a "Linux + Ansible together" learning track for a DevOps/SRE profile.

Applied lens: none (not a spec-project.md; this was a free-form brainstorm on project design + learning path).

---

## 1. Context and motivation

Stated goal:

> "Learn Ansible and Linux together — hardening and tuning configurations essential for DevOps, i.e. standard configurations every application-hosting server must have."

The project has a dual nature:

1. **Learning track** — each role becomes a complete "lesson": one Linux domain + the Ansible concepts it exercises. Already materialised in [`prompt.md`](../prompt.md) in the parent folder (learning system prompt with method CONCEPT → LINUX → MANUAL → ANSIBLE → VALIDATE → TROUBLESHOOT).
2. **Reusable asset** — the final product is a library of Ansible roles applicable to any future VPS/EC2 (Kriolu Kloud, Bussola, clients).

The project is essentially **Linux System Engineering** (the *content*: kernel, systemd, filesystem, networking, users…), executed with **DevOps practice** (the *how*: declarative IaC, versioned, idempotent), with an **SRE mindset** (the *feedback loop*: Lynis score, Molecule tests, drift detection).

---

## 2. Scope

### In-scope

- **OS-level** baseline — configuration of the operating system itself
- **Multi-distro** with family-based abstraction (`ansible_os_family`)
- **Heterogeneous fleet** — multiple hosts, different distros, same playbook
- **Diagnostics + troubleshooting** (tools installed + documented runbooks)
- **Basic observability** (node_exporter + tools: `ss`, `tcpdump`, `htop`, `iotop`, `sysstat`)
- Automated validation with **Lynis** + local testing with **Molecule**
- **Rollback procedure** documented per role
- Configuration framing in 5 categories: DEFAULT / RECOMMENDED / ENVIRONMENT-DEPENDENT / SECURITY-HARDENED / PERFORMANCE-TUNED

### Out-of-scope (for now)

- **Application stack** (nginx/Traefik, Docker runtime, backup agents) — not part of the baseline
- **Server-specific roles** (webserver vs database vs bastion) — all hosts receive the same baseline
- **CI/CD** (GitHub Actions matrix) — deferred to phase 2, all local for now
- **Ansible Collection** (`namespace.collection`) — Option B (multi-role + playbook) is sufficient; migrating to a collection is trivial later
- **AlmaLinux 9** — redundant with Rocky 9 (same RHEL family, bug-for-bug)
- **CentOS Linux legacy / CentOS Stream** — CentOS 7/8 EOL; Stream is upstream of RHEL, not recommended for conservative production

---

## 3. Supported distros

Declared support vs tested matrix:

| Distro | Family | Declared support | Tested locally | Reason |
|---|---|---|---|---|
| **Ubuntu 24.04 LTS** | Debian | ✅ | ✅ | Most common on modern VPS |
| **Debian 12** | Debian | ✅ | ✅ | Stable base, openclaw VPS |
| **Rocky Linux 9** | RHEL | ✅ | ✅ | Represents RHEL family in CI |
| **Amazon Linux 2023** | RHEL | ✅ | ✅ | EC2 coverage |
| **RHEL 9** | RHEL | ✅ (declared) | ⚠️ manual smoke-test on dev EC2 | Family coverage via Rocky |
| **AlmaLinux 9** | RHEL | ✅ (declared) | ❌ | Redundant with Rocky |

**Strategy:** develop/test on Rocky 9 (represents the RHEL family). If a client requires real RHEL, spin up a RHEL 9 EC2 via the [Red Hat Developer Program](https://developers.redhat.com) (16 free subscriptions) and run the playbook.

---

## 4. Technical roles and how they relate in this project

| Role | Focus | How it enters the project |
|---|---|---|
| **Linux System Engineer** | The OS itself | Defines **what** to harden (SSH, firewall, kernel, sysctl…) |
| **DevOps Engineer** | Flow between code and production | Turns sysadmin knowledge into **reproducible code** (Ansible) |
| **SRE** | Reliability in production | Defines **how to validate** (Lynis score, Molecule, drift detection) |

---

## 5. Technical domains covered (17 domains)

Extracted from `prompt.md` and mapped to Ansible roles:

1. Operating system (hostname, timezone, locale, repos)
2. Users & access (users, groups, SSH keys, sudo, password policy)
3. SSH hardening (sshd_config, auth, ciphers)
4. Firewall (host firewall + relationship with cloud SG + service binding — 3 layers)
5. Systemd (units, targets, restart policies, resource controls: `CPUQuota`, `MemoryMax`)
6. Processes (`ps`, `top`, signals, states, zombies)
7. Memory (RAM, swap, OOM Killer, `/proc/meminfo`, `vmstat`)
8. CPU (utilization vs load avg, context switching, CPU steal, affinity)
9. Storage (partitions, filesystems, mounts, inodes, `iostat`)
10. Networking (interfaces, routing, DNS, TCP/UDP, `ss`, `ip`, `tcpdump`)
11. Kernel + sysctl (`/proc`, `/sys`, `sysctl.d`)
12. Resource limits (`ulimit`, `limits.conf`, systemd limits)
13. File descriptors (EMFILE, ENFILE, "too many open files")
14. Logs (journald, journalctl, rsyslog, rotation)
15. Time sync (chrony, drift, TLS/logs/auth dependency)
16. Security (least privilege, SSH, firewall, SELinux/AppArmor, secrets, updates, auditd)
17. Performance & tuning (scientific method: measure → hypothesis → change one variable → measure)

---

## 6. Ansible project structure

Adopted pattern: **Option B — multiple thin roles + orchestrating playbook**. Reasons: each role is isolated and testable, reusable outside the baseline, each role becomes a lesson, easy migration to an Ansible Collection later.

```
ansible-linux/
├── ansible.cfg
├── requirements.yml
├── prompt.md                          # learning system prompt (existing)
├── README.md
├── inventories/
│   ├── dev/
│   │   ├── hosts.yml
│   │   └── group_vars/all.yml
│   ├── staging/
│   │   ├── hosts.yml
│   │   └── group_vars/all.yml
│   └── production/
│       ├── hosts.yml
│       ├── group_vars/all.yml         # stricter overrides
│       └── host_vars/
├── group_vars/
│   ├── all.yml                        # global defaults
│   ├── debian_family.yml              # Ubuntu/Debian overrides
│   ├── redhat_family.yml              # Rocky/Amazon Linux overrides
│   └── amazon_linux.yml               # AL2023-specific
├── playbooks/
│   ├── baseline.yml                   # applies all roles in order
│   ├── hardening.yml                  # security-only subset
│   └── diagnostics.yml                # installs/runs troubleshooting tools
├── roles/                             # 15 roles (see §7)
├── molecule/                          # test scenarios per distro
│   ├── ubuntu2404/
│   ├── debian12/
│   ├── rocky9/
│   └── amazonlinux2023/
└── docs/
    ├── brainstorm.md                  # this document
    ├── runbooks/                      # troubleshooting guides
    │   ├── ssh-locked-out.md
    │   ├── disk-full-vs-inodes.md
    │   ├── oom-killer.md
    │   ├── high-load-avg.md
    │   └── connection-refused.md
    ├── categories.md                  # 5-category framing
    └── rollback-procedures.md         # per role
```

---

## 7. The 15 baseline roles

Order by **increasing risk** (the same sequence suggested for building/learning):

| # | Role | Domain | Lock-out risk |
|---|---|---|---|
| 1 | `baseline_common` | hostname, timezone, locale, motd | 🟢 None |
| 2 | `baseline_packages` | repos, essential packages, unattended-upgrades / dnf-automatic | 🟢 None |
| 3 | `baseline_time_sync` | chrony | 🟢 None |
| 4 | `baseline_logging` | journald size, rsyslog, log rotation | 🟢 None |
| 5 | `baseline_limits` | ulimits, file descriptors, systemd limits | 🟢 None (only active in new session) |
| 6 | `baseline_kernel` | sysctl (network, memory, ASLR), module blacklist | 🟡 Reversible via reboot |
| 7 | `baseline_filesystem` | mount options, critical permissions, SUID audit | 🟡 Watch `noexec` on `/tmp` |
| 8 | `baseline_systemd` | service hardening, resource controls | 🟡 Low |
| 9 | `baseline_observability` | node_exporter + diagnostic tools | 🟢 None |
| 10 | `baseline_users` | deploy user, sudo, password policy | 🟡 Watch sudo NOPASSWD |
| 11 | `baseline_ssh` | sshd hardening | 🔴 Can lock you out — always `--check` first |
| 12 | `baseline_firewall` | UFW/firewalld/nftables abstracted | 🔴 Can lock you out — always `--check` first |
| 13 | `baseline_audit` | auditd + AIDE + fail2ban | 🟡 Initial noise possible |
| 14 | `baseline_mac` | AppArmor / SELinux | 🔴 Enforcing may break apps — careful |
| 15 | `baseline_tuning` | TCP stack, memory, IO scheduler | 🟡 Noticeable under load, reversible |

**Rule of thumb:** the 3 riskiest (SSH, firewall, MAC) only reach production after running in dev/staging via Molecule, plus `ansible-playbook --check --diff` against real production before the real apply.

---

## 8. Technical patterns

### 8.1 Family-based abstraction (role public API)

Roles expose **distro-agnostic** variables and internally dispatch by family:

```yaml
# defaults/main.yml — clean public API
baseline_ssh_port: 22
baseline_firewall_allowed_ports: [22, 443]
baseline_admin_user: deploy
baseline_admin_ssh_keys:
  - "ssh-ed25519 AAAA..."
```

```
roles/baseline_firewall/tasks/
├── main.yml          # includes variant by ansible_os_family
├── Debian.yml        # installs and configures UFW
└── RedHat.yml        # installs and configures firewalld
```

The role consumer **does not know** which firewall runs underneath. The contract is "allow ports [X, Y, Z]".

This is what separates "playbook that works on my Ubuntu" from "professional collection".

### 8.2 5-category framing per parameter

Every configuration parameter belongs to one of these 5 boxes:

- **DEFAULT** — what the distro ships. Documented, not changed
- **RECOMMENDED** — change the community/CIS/vendor recommends with a mild trade-off
- **ENVIRONMENT-DEPENDENT** — varies per role/env (e.g. dev may keep `PermitPasswordAuthentication yes`; prod does not)
- **SECURITY-HARDENED** — parameter with clear security impact, operational cost accepted
- **PERFORMANCE-TUNED** — parameter with an associated performance metric, measured before/after

Documented in `docs/categories.md`. For each baseline change, the role indicates which box it belongs to.

### 8.3 Rollback procedure per role

Each role has a `rollback` section documented in `docs/rollback-procedures.md`: command/playbook to undo, backup file generated (`.orig` via `ansible.builtin.copy` with `backup: yes`), safe test procedure.

---

## 9. Environments: *ephemeral* model

Since there is **only one real production VPS** (openclaw), maintaining persistent dev/staging environments makes no sense. Adopted model:

| Environment | Machine | Duration |
|---|---|---|
| **dev** | Docker container (via Molecule) | Seconds, disposable |
| **staging** | Temporary EC2 (`t3.micro` or `t4g.small`) | Minutes to hours, destroyed after test |
| **production** | Real VPS (openclaw) or client's permanent EC2 | Persistent |

Flow: role edited → `molecule test` (Docker) → spin up temporary EC2 → real `ansible-playbook` → validate with Lynis → destroy EC2 → apply to production with `--check --diff` first, then apply.

`inventories/staging/hosts.yml` is versioned in the repo but updated each time a new EC2 is spawned (separate Terraform, or manual).

---

## 10. Validation

| Tool | Where it runs | What it validates |
|---|---|---|
| **ansible-lint** | Local, pre-commit | Ansible code quality (YAML, best practices, syntax) |
| **Molecule** (Docker driver) | Local, fast dev loop | Idempotency (run 2×, 2nd must be NO-CHANGE), converge, verify |
| **Lynis** | Inside Molecule scenario, post-converge step | Hardening score. Initial target: >75 |
| **`--check --diff`** | Manual, against real production before apply | Preview of what would change, without applying |
| **Manual smoke-test on real EC2** | Before closing a milestone | Cover the Docker vs real VM gap (systemd/SELinux/kernel) |

---

## 11. Implementation tools + choices

| Decision | Choice | Reason |
|---|---|---|
| **Molecule driver** | Docker (`molecule-plugins[docker]` + `geerlingguy/docker-*-ansible` images) | Fast (seconds), functional systemd via Geerlingguy images, covers 95%. VM only when kernel-level testing (SELinux enforcing, seccomp) is needed |
| **Secrets management** | Ansible Vault | Native, portable, no extra moving parts. SOPS + age is an optional upgrade later |
| **CI/CD** | None now, all local | Deferred to phase 2. GitHub Actions matrix (4 distros) once the project stabilises |
| **Structure** | Multi-role + playbook (Option B) | Each role isolated, reusable, testable. Not a Collection (overhead without benefit now) |
| **Distros in local CI** | Ubuntu 24.04, Debian 12, Rocky 9, Amazon Linux 2023 | 2 families × 2 representative distros each |

---

## 12. Consolidated decisions

| Decision | Choice | Justification | State |
|---|---|---|---|
| Scope | OS-level + diagnostics + observability, no app stack | Focus on "every machine needs this" | Decided |
| Multi-distro | Ubuntu 24.04, Debian 12, Rocky 9, Amazon Linux 2023 | 2 families covered, different package managers | Decided |
| Heterogeneous fleet | Yes (groups by family + function) | Reflects real production | Decided |
| Per-server roles | No (pure baseline, all equal) | Simpler; per-role differentiation is a phase 2 concern | Decided |
| Environments | dev (Docker) / staging (ephemeral EC2) / production (real) | Zero cost of idle infra | Decided |
| Structure | Option B — multi-role + orchestrating playbook | Modular, testable, learn by layers | Decided |
| Roles | 15 roles (see §7) | Covers 17 technical domains with useful granularity | Decided |
| 5-category framing | DEFAULT / RECOMMENDED / ENV-DEPENDENT / SEC-HARDENED / PERF-TUNED | Prevents blind "best practice" application | Decided |
| Rollback documented per role | Yes, in `docs/rollback-procedures.md` | Safe production operation | Decided |
| Validation | ansible-lint + Molecule + Lynis (>75) + `--check --diff` | Covers lint + idempotency + hardening score + preview | Decided |
| Molecule driver | Docker | Fast, systemd via Geerlingguy images | Decided |
| Secrets | Ansible Vault | Native, no overhead | Decided |
| CI/CD | Deferred | Local first, GitHub Actions in phase 2 | Decided |
| Real RHEL 9 | Declared, not in the dev loop | Coverage via Rocky 9; manual smoke-test when a client requires it | Decided |
| AlmaLinux 9 | Out | Redundant with Rocky | Decided |
| Location | `company/projects/kriolu-kloud.cv/devops/configuration-management/ansible-linux/` | Where `prompt.md` already lives | Inferred (confirm) |
| Project language (docs + code) | English | Consistency across projects (per user feedback) | Decided |

---

## 13. Open items

- **Specific construction order** — proposed in §7 (by increasing risk), but may change if the pedagogical goal prioritises another sequence (e.g. start with SSH because it is the most critical and immediate)
- **Runbooks to write** — initial list in §6 (5 runbooks), but the real set will emerge as problems appear
- **Lynis score target threshold** — 75 is an initial guess. Adjust after first runs per distro
- **Secret strategy in the repo** — Ansible Vault decided, but still to define: one global vault vs vault per environment
- **Terraform for spinning up staging EC2** — implicit in the ephemeral model but not designed. Could be a sibling `terraform/` folder or use Ansible + AWS collection directly

---

## 14. Discarded alternatives (recorded to avoid re-debate)

| Discarded | Reason |
|---|---|
| **Single monolithic role (`baseline`)** | `defaults/main.yml` would become a monster; not reusable; Molecule always tests everything together |
| **Ansible Collection (`namespace.baseline`)** | Conceptual overhead without benefit (not publishing to Galaxy now); migration is trivial later |
| **Multi-distro Debian-family-only** | Does not force the correct family-abstraction design — that pattern is the point of the exercise |
| **CentOS Linux 7/8** | EOL since 2021/2024, compliance/CVE risk |
| **CentOS Stream** | Upstream of RHEL, not recommended for conservative production |
| **AlmaLinux 9 in CI** | Redundant with Rocky 9 (both are RHEL 9 clones) |
| **Persistent dev/staging environments** | Idle infra cost; ephemeral model solves it with on-demand EC2 |
| **CI/CD from day 1** | Friction without gain; local Molecule + lint covers 95% now |
| **SOPS or external vault (HashiCorp Vault)** | Overkill; native Ansible Vault is enough for the context |
| **`monitoring/` as an app-stack role** | Out of declared scope; `baseline_observability` only installs tools, not service config |

---

## 15. Next steps after the brainstorm

Not commitments — just the natural sequence when leaving brainstorm mode:

1. Confirm the definitive project location (accept or move the folder)
2. Create the project skeleton (`ansible.cfg`, `requirements.yml`, `inventories/`, empty `roles/`)
3. Write `docs/categories.md` (5-category framing)
4. Build the **1st role** (`baseline_common`) end-to-end as the canonical reference:
   - Structure `defaults/`, `tasks/`, `handlers/`, `meta/`
   - Task dispatch by `ansible_os_family`
   - Molecule scenario for the 4 distros
   - Rollback doc
5. Replicate the pattern in the following roles in the order of §7

---

## 16. References

- [`../prompt.md`](../prompt.md) — learning system prompt (17 Linux domains + pedagogical method)
- [`/home/stevenalves/Desktop/openclaw-course/CLAUDE.md`](/home/stevenalves/Desktop/openclaw-course/CLAUDE.md) — global repo instructions
- [Red Hat Developer Program](https://developers.redhat.com) — 16 free RHEL subscriptions for dev
- [Geerlingguy Docker Ansible images](https://hub.docker.com/u/geerlingguy) — Molecule images with functional systemd
- [Lynis](https://cisofy.com/lynis/) — hardening validator
- [Ansible-Lockdown / dev-sec collections](https://github.com/dev-sec/ansible-collection-hardening) — reference for multi-distro patterns (not used directly, but useful for comparison)
