# Rollback procedures

One section per role. A role in production without a documented rollback is a footgun.

Each section must answer:
1. **What did the role change?** — files edited, packages installed, services enabled.
2. **How to undo?** — inverse playbook, inverse Ansible tags, or manual steps.
3. **Where is the backup?** — every `template:` / `copy:` / `lineinfile:` in the role uses `backup: yes`; note the resulting `.orig` file path.
4. **How to validate the rollback worked?** — a specific check (service running, port listening, config line present).

## Template — copy this for each new role

### baseline_<role_name>

**Changed:**
- TODO

**Undo:**
```bash
# TODO: inverse playbook or manual steps
```

**Backup location:**
- TODO: e.g. `/etc/ssh/sshd_config.orig` (created by `backup: yes` on the template task)

**Validate:**
```bash
# TODO: e.g. sshd -t && ss -lnt | grep :22
```

### baseline_common

**Changed:**
- `/etc/hostname` and `/etc/hosts` (127.0.1.1 line) — hostname tasks
- `/etc/localtime` symlink — timezone task
- `/etc/motd` — MOTD task
- `/etc/locale.gen` and `/etc/default/locale` (Debian) — locale tasks
- `/etc/locale.conf` (RedHat) — locale task
- Packages installed: curl, wget, vim, htop, unzip, ca-certificates (+ extra_packages)

**Undo:**
```bash
# Restore backed-up config files (backups created with backup: true)
# Find the most recent backup and restore it, e.g.:
#   mv /etc/motd.2026-09-28@10:00~ /etc/motd
#   mv /etc/locale.gen.2026-09-28@10:00~ /etc/locale.gen

# Revert hostname (replace OLD_HOSTNAME with the original)
hostnamectl set-hostname OLD_HOSTNAME

# Remove packages if they were not present before (careful — other roles may depend on them)
# apt remove curl wget vim htop unzip ca-certificates  # Debian
# dnf remove curl wget vim htop unzip ca-certificates  # RedHat
```

**Backup location:**
- `/etc/motd.<timestamp>~` — created by `backup: true` on the MOTD copy task
- `/etc/locale.gen.<timestamp>~` — created by `backup: true` on the locale.gen lineinfile task
- `/etc/default/locale.<timestamp>~` — Debian only
- `/etc/locale.conf.<timestamp>~` — RedHat only
- `/etc/hosts.<timestamp>~` — created by `backup: true` on the hosts lineinfile task

**Validate:**
```bash
# Hostname
hostname -f

# Timezone
date +%Z   # should show UTC (or the new timezone)

# Locale (Debian)
grep LANG /etc/default/locale

# Locale (RedHat)
grep LANG /etc/locale.conf

# Packages
curl --version && wget --version
```

### baseline_packages

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_time_sync

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_logging

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_limits

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_kernel

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_filesystem

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_systemd

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_observability

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_users

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_ssh

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_firewall

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_audit

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_mac

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```

### baseline_tuning

**Changed:**
- TODO

**Undo:**
```bash
# TODO
```

**Backup location:**
- TODO

**Validate:**
```bash
# TODO
```
