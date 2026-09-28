# baseline_time_sync

## Purpose

Installs and configures `chrony` as the NTP daemon on both Debian-family (Ubuntu, Debian) and RedHat-family (Rocky, RHEL, Amazon Linux) hosts. Ensures accurate, stable time synchronisation with configurable NTP server pools, clock step thresholds, and optional LAN client serving.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_time_sync_ntp_servers` | list | `[0-3].pool.ntp.org` | RECOMMENDED | List of NTP pool servers. Adjust to a regional pool for lower latency. |
| `baseline_time_sync_makestep_threshold` | float | `1.0` | DEFAULT | Maximum offset (seconds) for which chrony will step the clock on startup. |
| `baseline_time_sync_makestep_limit` | int | `3` | DEFAULT | Number of initial clock updates during which stepping is allowed. |
| `baseline_time_sync_rtcsync` | bool | `true` | RECOMMENDED | Sync the hardware RTC to the system clock periodically. |
| `baseline_time_sync_allow_cidr` | string | `""` | ENVIRONMENT-DEPENDENT | CIDR range allowed to query this host as an NTP server. Empty = NTP server mode disabled. |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.builtin` (included with ansible-core)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_time_sync
```

## Rollback

See the 'baseline_time_sync' section in `docs/rollback-procedures.md`.
