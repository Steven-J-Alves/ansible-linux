# baseline_logging

## Purpose

Configures `systemd-journald` with size limits and retention policies to prevent unbounded disk usage, and ensures `rsyslog` is installed and running on both Debian and RedHat families. Optionally configures forwarding of all logs to a remote syslog server over UDP or TCP.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_logging_journal_max_use` | string | `"500M"` | RECOMMENDED | Maximum total disk space used by the journal. |
| `baseline_logging_journal_max_file_size` | string | `"50M"` | DEFAULT | Maximum size of each individual journal file. |
| `baseline_logging_journal_max_retention_days` | int | `0` | DEFAULT | Days to retain journal files. 0 = no time-based limit (rely on max_use). |
| `baseline_logging_journal_compress` | bool | `true` | RECOMMENDED | Compress journal files on disk to save space. |
| `baseline_logging_remote_host` | string | `""` | ENVIRONMENT-DEPENDENT | Hostname or IP of the remote syslog server. Empty = forwarding disabled. |
| `baseline_logging_remote_port` | int | `514` | DEFAULT | Destination port for remote syslog forwarding. |
| `baseline_logging_remote_protocol` | string | `"udp"` | DEFAULT | Transport for remote syslog: `udp` (single `@`) or `tcp` (double `@@`). |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.builtin` (included with ansible-core)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_logging
```

## Rollback

See the 'baseline_logging' section in `docs/rollback-procedures.md`.
