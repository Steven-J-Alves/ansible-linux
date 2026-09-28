# baseline_limits

## Purpose

Sets file descriptor and process limits in `/etc/security/limits.conf` and `/etc/systemd/system.conf`. Changes take effect on next login or new process spawn — no restart required.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_limits_nofile_soft` | int | `65536` | RECOMMENDED | Soft limit for open file descriptors per process |
| `baseline_limits_nofile_hard` | int | `65536` | RECOMMENDED | Hard limit for open file descriptors per process |
| `baseline_limits_nproc_soft` | int | `4096` | RECOMMENDED | Soft limit for number of processes per user |
| `baseline_limits_nproc_hard` | int | `4096` | RECOMMENDED | Hard limit for number of processes per user |
| `baseline_limits_memlock_soft` | int | `-1` | DEFAULT | Soft limit for locked memory in kB (-1 = unlimited) |
| `baseline_limits_memlock_hard` | int | `-1` | DEFAULT | Hard limit for locked memory in kB (-1 = unlimited) |
| `baseline_limits_target_user` | string | `"*"` | DEFAULT | User or wildcard to apply limits to |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_limits
```

## Rollback

See the 'baseline_limits' section in `docs/rollback-procedures.md`.
