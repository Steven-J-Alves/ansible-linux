# baseline_mac

## Purpose

Installs and configures Mandatory Access Control (MAC): AppArmor on Debian-family hosts and SELinux on RedHat-family hosts. By default the role installs the tooling and leaves MAC in permissive/complaining mode (`baseline_mac_enforcing: false`) so it can be observed without breaking applications. Set `baseline_mac_enforcing: true` only after validating that no required process is blocked.

**Risk:** Switching SELinux from permissive to enforcing can break applications that lack correct policy labels. Always test with `baseline_mac_enforcing: false` first.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_mac_enforcing` | bool | `false` | SECURITY-HARDENED | Enable enforcement mode (enforcing/complaining vs permissive) |
| `baseline_mac_apparmor_enforce_profiles` | list | `[]` | SECURITY-HARDENED | AppArmor profiles to set to enforce (Debian only) |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.posix` (for `selinux` module on RedHat)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_mac
```

## Rollback

On Debian: `systemctl stop apparmor`. On RedHat: set `baseline_mac_enforcing: false` and re-run, or run `setenforce 0` immediately and edit `/etc/selinux/config` to set `SELINUX=permissive`.
