# TRD — Technical Requirements Document

> Global technical document for the project. Created and maintained via the `write-trd` skill.
> Low granularity: covers what is global and stable. Fine-grained rules live in ADRs.

---

## Stack

| Dimension | Value |
|---|---|
| Primary language | YAML (playbooks, roles, inventories) |
| Runtime / platform | Ansible Core ≥ 2.15 (Python 3.9+ on the control node) |
| Primary framework | Multi-role + orchestrating playbook (Option B — not a Collection) |
| Database | N/A |
| Test tools | Molecule (Docker driver) · ansible-lint · yamllint · Lynis |
| Package manager | ansible-galaxy (collections via `requirements.yml`) |

---

## Architecture

### Architectural pattern

Multi-role library with an orchestrating playbook. 15 thin `baseline_*` roles, each
isolated and independently testable, composed by `playbooks/baseline.yml`.
Family-based abstraction via `ansible_os_family` decouples role logic from
distribution strings.

Chosen over a single monolithic role (untestable, non-reusable) and over an Ansible
Collection (overhead without benefit now — migration is trivial later).

### Directory structure

```
ansible-linux/
├── ansible.cfg              # project config (stdout_callback=yaml, retry disabled)
├── requirements.yml         # collections pinned with == (reproducibility)
├── inventories/
│   ├── dev/                 # Docker/Molecule hosts (ephemeral)
│   ├── staging/             # ephemeral EC2 (spun up per test run, destroyed after)
│   └── production/          # real VPS or permanent EC2
├── group_vars/
│   ├── all.yml              # global defaults
│   ├── debian_family.yml    # Ubuntu + Debian overrides
│   ├── redhat_family.yml    # Rocky + Amazon Linux overrides
│   └── amazon_linux.yml     # AL2023-specific where needed
├── playbooks/
│   ├── baseline.yml         # applies all 15 roles in risk order
│   ├── hardening.yml        # security-only subset
│   └── diagnostics.yml      # installs troubleshooting tools
├── roles/                   # 15 baseline_* roles
├── molecule/                # per-role scenarios (4 distros each)
└── docs/
```

### Main modules / layers

| Module | Responsibility |
|---|---|
| `baseline_common` | Hostname, timezone, locale, MOTD, base repos |
| `baseline_packages` | Package management, unattended-upgrades / dnf-automatic |
| `baseline_time_sync` | Chrony, NTP drift |
| `baseline_logging` | Journald sizing, rsyslog, log rotation |
| `baseline_limits` | ulimits, file descriptors, systemd resource limits |
| `baseline_kernel` | sysctl (network, memory, ASLR), module blacklist |
| `baseline_filesystem` | Mount options, permissions, SUID audit |
| `baseline_systemd` | Service hardening, CPUQuota, MemoryMax |
| `baseline_observability` | node_exporter + diagnostic tools (ss, htop, iotop, sysstat) |
| `baseline_users` | deploy user, sudo policy, password policy |
| `baseline_ssh` | sshd hardening — port, ciphers, auth, MaxAuthTries |
| `baseline_firewall` | UFW (Debian) / firewalld (RHEL) via ansible_os_family |
| `baseline_audit` | auditd, AIDE, fail2ban |
| `baseline_mac` | AppArmor (Debian) / SELinux (RHEL) |
| `baseline_tuning` | TCP stack, memory, I/O scheduler tuning |

---

## Non-Functional Requirements

| Dimension | Requirement |
|---|---|
| Idempotency | `CHANGED=0` on second run with identical inputs — enforced by Molecule's idempotency step |
| Multi-distro | All roles work on Ubuntu 24.04, Debian 12, Rocky 9, Amazon Linux 2023 without distro-string checks |
| Hardening score | Lynis > 75 post-apply (initial target; adjust per distro after first runs) |
| Safety | `baseline_ssh` / `baseline_firewall` / `baseline_mac` require `--check --diff` on a staging EC2 before production apply |
| Testability | One Molecule scenario per declared distro; `verify.yml` has ≥1 real assertion |
| Reproducibility | Collections pinned with `==` in `requirements.yml`; no open constraints (`>=`, `~>`) |

---

## External Dependencies

| Service / System | Type | Relevant constraint | Owner |
|---|---|---|---|
| Docker Hub (Geerlingguy images) | Container registry | 100 pulls/6h unauthenticated — relevant when CI added in phase 2 | external |
| Ansible Galaxy | Package registry | No documented hard rate limit; `==` pins avoid redundant downloads | external |
| EC2 staging | Cloud VM | Ephemeral `t3.micro` / `t4g.small`; ~$0.01/h; must be destroyed after each test run | AWS |
| Red Hat Developer Program | Dev subscription | 16 free RHEL 9 subscriptions for dev/smoke-test on real RHEL | external |

---

## Standards

### Tests

| Item | Value |
|---|---|
| Framework | Molecule (Docker driver) + `geerlingguy/docker-*-ansible` images |
| Command | `molecule test -s <distro>` (inside each role dir) |
| Coverage | One scenario per declared distro; idempotency step not disabled |
| Strategy | converge → idempotency check → verify; Lynis run post-converge for hardening roles |
| Static analysis | `ansible-lint --profile production` + `yamllint` before merging any role |

### Code style

- **Linter:** `ansible-lint --profile production`
- **YAML style:** `yamllint`
- **Naming:** roles `baseline_<snake_case>`, variables `baseline_<role>_<name>`
- **Family dispatch:** `ansible_os_family` only — never `ansible_distribution ==` checks
- **Language:** English-only in all code, comments, and docs

### Error handling

Tasks use explicit `state:` where the module supports it. `command:` / `shell:` tasks
declare `changed_when:` and `failed_when:`. Handlers use `listen:` for cross-family restart
coordination. Config-overwriting tasks use `backup: yes`.

### Secrets

Ansible Vault for all sensitive values. No hardcoded secrets in any file.
SOPS + age is a deferred upgrade option.

### 5-Category framing

Every variable in `defaults/main.yml` labelled: `DEFAULT` / `RECOMMENDED` /
`ENVIRONMENT-DEPENDENT` / `SECURITY-HARDENED` / `PERFORMANCE-TUNED`.
Full reference: `docs/categories.md`.

---

## Global Decisions (ADRs)

| # | Title | Date | Status | Link |
|---|---|---|---|---|
| 001 | Multi-role + orchestrating playbook over monolithic role or Collection | 2026-09-28 | accepted | [adrs/001](adrs/001-multi-role-playbook-over-collection.md) |
| 002 | Family-based dispatch via ansible_os_family, never ansible_distribution strings | 2026-09-28 | accepted | [adrs/002](adrs/002-family-dispatch-ansible-os-family.md) |
| 003 | Molecule with Docker driver (Geerlingguy images) as primary test framework | 2026-09-28 | accepted | [adrs/003](adrs/003-molecule-docker-driver.md) |
| 004 | Ephemeral environment model (dev=Docker, staging=EC2 on-demand, production=real) | 2026-09-28 | accepted | [adrs/004](adrs/004-ephemeral-environments.md) |
| 005 | Ansible Vault for secrets management | 2026-09-28 | accepted | [adrs/005](adrs/005-ansible-vault-secrets.md) |
