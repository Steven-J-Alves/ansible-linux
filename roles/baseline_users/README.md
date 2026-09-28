# baseline_users

## Purpose

Creates a dedicated deploy/ops user with configurable SSH key authorisation and sudo access, then enforces organisation-wide password aging policy via `/etc/login.defs`. The sudo entry is written to `/etc/sudoers.d/` and validated with `visudo` before being installed, so a syntax error cannot lock you out.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_users_deploy_enabled` | bool | `true` | RECOMMENDED | Toggle user creation entirely |
| `baseline_users_deploy_name` | string | `deploy` | RECOMMENDED | Username for the ops account |
| `baseline_users_deploy_uid` | int | `1001` | RECOMMENDED | Fixed UID to keep consistent across hosts |
| `baseline_users_deploy_groups` | list | `[sudo, wheel]` | RECOMMENDED | Supplementary groups (sudo for Debian, wheel for RedHat) |
| `baseline_users_deploy_shell` | string | `/bin/bash` | DEFAULT | Login shell |
| `baseline_users_deploy_ssh_keys` | list | `[]` | ENVIRONMENT-DEPENDENT | Public keys to authorise; must be set in production |
| `baseline_users_deploy_nopasswd_sudo` | bool | `false` | SECURITY-HARDENED | Set true only in ephemeral/CI environments |
| `baseline_users_password_min_length` | int | `14` | SECURITY-HARDENED | Minimum password length |
| `baseline_users_password_min_days` | int | `1` | SECURITY-HARDENED | Days before a password can be changed again |
| `baseline_users_password_max_days` | int | `90` | SECURITY-HARDENED | Maximum password age in days |
| `baseline_users_password_warn_days` | int | `7` | DEFAULT | Warning days before expiry |

## Dependencies

- ansible-core >= 2.15
- Collections: `ansible.posix` (for `authorized_key`)

## Minimal usage

```yaml
- hosts: all
  become: true
  vars:
    baseline_users_deploy_ssh_keys:
      - "ssh-ed25519 AAAA... operator@example.com"
  roles:
    - baseline_users
```

## Rollback

Remove the user with `userdel -r deploy`, delete `/etc/sudoers.d/deploy`, and revert `/etc/login.defs` from the `.bak` file the role creates automatically.
