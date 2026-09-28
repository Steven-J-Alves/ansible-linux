# baseline_filesystem

## Purpose

Hardens filesystem permissions on critical system files (`/etc/passwd`, `/etc/shadow`, `/etc/group`, `/etc/gshadow`) and optionally removes SUID/SGID bits from specified binaries. On RedHat-family hosts, ensures the `shadow` group exists before applying shadow file ownership.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_filesystem_secure_permissions` | bool | `true` | SECURITY-HARDENED | Set restrictive permissions on sensitive system files |
| `baseline_filesystem_remove_suid` | list | `[]` | SECURITY-HARDENED | Paths of binaries from which to remove SUID/SGID bits |
| `baseline_filesystem_tmp_hardening` | bool | `false` | SECURITY-HARDENED | Ensure /tmp is mounted noexec,nosuid,nodev (disable for container workloads) |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_filesystem
```

## Rollback

See the 'baseline_filesystem' section in `docs/rollback-procedures.md`.
