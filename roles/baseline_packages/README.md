# baseline_packages

## Purpose

Manages OS package repositories, installs operator-specified extra packages, and enables automatic security updates. On Debian-family hosts it installs and configures `unattended-upgrades`; on RedHat-family hosts it installs `dnf-automatic` and configures it for security-only updates via a systemd timer.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_packages_extra` | list | `[]` | ENVIRONMENT-DEPENDENT | Extra packages to install beyond the role defaults. |
| `baseline_packages_auto_update_enabled` | bool | `true` | RECOMMENDED | Enable automatic security updates (unattended-upgrades on Debian, dnf-automatic on RedHat). |
| `baseline_packages_unattended_mail` | string | `""` | ENVIRONMENT-DEPENDENT | Email address for unattended-upgrades error notifications. Empty = disabled. |
| `baseline_packages_unattended_autoremove` | bool | `true` | RECOMMENDED | Remove obsolete packages after upgrade (unattended-upgrades). |
| `baseline_packages_dnf_apply_updates` | string | `"security"` | SECURITY-HARDENED | dnf-automatic upgrade type: `security` (apply security updates only) or `default` (apply all). |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.builtin` (included with ansible-core)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_packages
```

## Rollback

See the 'baseline_packages' section in `docs/rollback-procedures.md`.
