# baseline_kernel

## Purpose

Applies security and performance sysctl parameters to `/etc/sysctl.d/99-baseline-kernel.conf` and optionally blacklists kernel modules via `/etc/modprobe.d/99-baseline-blacklist.conf`. Covers SYN flood protection, IP spoofing prevention, ICMP redirect hardening, ASLR, dmesg restriction, and inotify tuning.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_kernel_sysctl_params` | dict | see defaults | RECOMMENDED | Map of sysctl key-value pairs to apply |
| `baseline_kernel_blacklist_modules` | list | `[]` | SECURITY-HARDENED | Kernel modules to blacklist via modprobe.d |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.posix` (for `ansible.posix.sysctl`)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_kernel
```

## Rollback

See the 'baseline_kernel' section in `docs/rollback-procedures.md`.
