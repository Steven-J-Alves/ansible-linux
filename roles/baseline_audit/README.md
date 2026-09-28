# baseline_audit

## Purpose

Installs auditd for kernel-level system call auditing (writing events to `/var/log/audit/audit.log`) and fail2ban for automatic brute-force protection on SSH (and any other enabled jail). Both services are enabled at boot. Log rotation is tuned to keep a configurable number of files capped at a configurable size.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_audit_auditd_enabled` | bool | `true` | SECURITY-HARDENED | Install and enable auditd |
| `baseline_audit_max_log_file` | int | `50` | DEFAULT | Max log file size in MB |
| `baseline_audit_max_log_file_action` | string | `"rotate"` | DEFAULT | Action when log reaches max size |
| `baseline_audit_num_logs` | int | `5` | DEFAULT | Number of rotated logs to retain |
| `baseline_audit_fail2ban_enabled` | bool | `true` | SECURITY-HARDENED | Install and enable fail2ban |
| `baseline_audit_fail2ban_maxretry` | int | `5` | SECURITY-HARDENED | Failed attempts before ban |
| `baseline_audit_fail2ban_bantime` | int | `3600` | SECURITY-HARDENED | Ban duration in seconds |
| `baseline_audit_fail2ban_findtime` | int | `600` | DEFAULT | Window in seconds for counting failures |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_audit
```

## Rollback

To disable auditd: `systemctl stop auditd && systemctl disable auditd`. To disable fail2ban: `systemctl stop fail2ban && systemctl disable fail2ban`. Both services can be toggled off by setting `baseline_audit_auditd_enabled: false` and `baseline_audit_fail2ban_enabled: false` and re-running the role.
