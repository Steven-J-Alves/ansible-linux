# baseline_systemd

## Purpose

Tunes systemd defaults, disables or masks unnecessary services, and restricts coredump storage. Sets `DefaultTimeoutStopSec` in `/etc/systemd/system.conf` to prevent slow shutdowns from blocking deploys, and writes `/etc/systemd/coredump.conf` to prevent core dumps from leaking sensitive process memory.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_systemd_disable_services` | list | `[]` | ENVIRONMENT-DEPENDENT | Services to disable and stop |
| `baseline_systemd_mask_services` | list | `[]` | SECURITY-HARDENED | Services to mask (stronger than disable) |
| `baseline_systemd_default_timeout_stop_sec` | int | `30` | RECOMMENDED | Default stop timeout in seconds for all services |
| `baseline_systemd_restrict_coredump` | bool | `true` | SECURITY-HARDENED | Write coredump.conf to disable core dump storage |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_systemd
```

## Rollback

See the 'baseline_systemd' section in `docs/rollback-procedures.md`.
