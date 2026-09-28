# baseline_observability

## Purpose

Installs passive diagnostic tools (sysstat, iotop, tcpdump, strace, lsof, net-tools, and family-specific packages) on every managed host. No daemons are started and no ports are opened — these are read-only investigative tools. On Debian-family hosts, sysstat data collection is enabled via `/etc/default/sysstat`.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_observability_packages_common` | list | `[sysstat, iotop, strace, tcpdump, lsof, net-tools, dnsutils]` | RECOMMENDED | Packages installed on all families |
| `baseline_observability_packages_debian` | list | `[traceroute, nmap, netcat-openbsd]` | DEFAULT | Extra packages for Debian/Ubuntu |
| `baseline_observability_packages_redhat` | list | `[traceroute, nmap, nc]` | DEFAULT | Extra packages for RedHat/Amazon Linux |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_observability
```

## Rollback

Uninstall the packages listed in `baseline_observability_packages_common` plus the family-specific list. On Debian hosts, revert `/etc/default/sysstat` by setting `ENABLED="false"` (the role creates a `.bak` backup automatically).
