# baseline_tuning

## Purpose

Applies TCP stack and memory performance tuning via `ansible.posix.sysctl`, writing all parameters to `/etc/sysctl.d/99-baseline-tuning.conf` so they persist across reboots. Optionally sets the I/O scheduler for a named block device via a `shell` write to the sysfs path (only used when `baseline_tuning_io_block_device` is set). This role is cross-family — no Debian.yml / RedHat.yml differentiation is needed.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_tuning_io_scheduler` | string | `"none"` | PERFORMANCE-TUNED | I/O scheduler: `none` for NVMe, `mq-deadline` for SATA SSD, `bfq` for HDD |
| `baseline_tuning_io_block_device` | string | `""` | ENVIRONMENT-DEPENDENT | Block device name (e.g. `sda`, `nvme0n1`). Empty = skip I/O scheduler task |
| `baseline_tuning_sysctl_params` | dict | see defaults | PERFORMANCE-TUNED | Map of sysctl key → value pairs to apply |

### Default sysctl parameters

| Key | Value | Purpose |
|---|---|---|
| `net.core.somaxconn` | `65535` | TCP connection backlog |
| `net.ipv4.tcp_max_tw_buckets` | `1440000` | TIME_WAIT bucket limit |
| `net.ipv4.tcp_tw_reuse` | `1` | Reuse TIME_WAIT sockets |
| `net.ipv4.tcp_fin_timeout` | `15` | FIN_WAIT_2 timeout in seconds |
| `net.core.rmem_max` | `16777216` | Max socket receive buffer |
| `net.core.wmem_max` | `16777216` | Max socket send buffer |
| `net.ipv4.tcp_rmem` | `4096 87380 16777216` | TCP receive buffer sizes |
| `net.ipv4.tcp_wmem` | `4096 65536 16777216` | TCP send buffer sizes |
| `vm.swappiness` | `10` | Prefer RAM over swap |
| `vm.dirty_ratio` | `15` | Max dirty page % before sync |
| `vm.dirty_background_ratio` | `5` | Background writeback threshold |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.posix` (for `sysctl` module)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_tuning
```

## Rollback

Remove `/etc/sysctl.d/99-baseline-tuning.conf` and run `sysctl --system` to reload defaults. The previous values will be reinstated from `/etc/sysctl.conf` and any remaining drop-in files. I/O scheduler changes are ephemeral (not persisted across reboot) unless you add a udev rule separately.
