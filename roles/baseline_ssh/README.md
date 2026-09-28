# baseline_ssh

## Purpose

Manages the full `/etc/ssh/sshd_config` via a Jinja2 template, enforcing CIS-aligned hardening: no root login, no password auth, strong ciphers/MACs/KexAlgorithms, idle-session timeout, and configurable `AllowUsers`/`AllowGroups`. The template is validated with `sshd -t -f %s` before being installed, so a bad configuration is rejected before it can take effect.

**LOCKOUT RISK:** Always run with `--check --diff` before applying to production. Ensure at least one key-authenticated user is in `baseline_ssh_allow_users` (or the list is empty) before setting `baseline_ssh_password_authentication: "no"`.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_ssh_port` | int | `22` | ENVIRONMENT-DEPENDENT | SSH listen port |
| `baseline_ssh_permit_root_login` | string | `"no"` | SECURITY-HARDENED | `no`, `prohibit-password`, or `yes` |
| `baseline_ssh_password_authentication` | string | `"no"` | SECURITY-HARDENED | Disable password auth |
| `baseline_ssh_permit_empty_passwords` | string | `"no"` | SECURITY-HARDENED | Reject empty passwords |
| `baseline_ssh_allow_users` | list | `[]` | ENVIRONMENT-DEPENDENT | Restrict login to named users |
| `baseline_ssh_allow_groups` | list | `[]` | ENVIRONMENT-DEPENDENT | Restrict login to named groups |
| `baseline_ssh_client_alive_interval` | int | `300` | RECOMMENDED | Idle timeout in seconds |
| `baseline_ssh_client_alive_count_max` | int | `2` | RECOMMENDED | Max missed keepalives before disconnect |
| `baseline_ssh_max_auth_tries` | int | `3` | SECURITY-HARDENED | Max auth attempts per connection |
| `baseline_ssh_x11_forwarding` | string | `"no"` | DEFAULT | X11 forwarding |
| `baseline_ssh_agent_forwarding` | string | `"no"` | DEFAULT | Agent forwarding |
| `baseline_ssh_ciphers` | string | chacha20+aes256+aes128-gcm | SECURITY-HARDENED | Allowed symmetric ciphers |
| `baseline_ssh_macs` | string | hmac-sha2-512+256-etm | SECURITY-HARDENED | Allowed MAC algorithms |
| `baseline_ssh_kex_algorithms` | string | curve25519+dh14-sha256 | SECURITY-HARDENED | Allowed key exchange algorithms |

## Dependencies

- ansible-core >= 2.15
- Collections: none

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_ssh
```

## Rollback

Restore the backup created by the role (`/etc/ssh/sshd_config.bak`) and restart sshd (`systemctl restart ssh` on Debian, `systemctl restart sshd` on RedHat). The backup is created automatically on every run where the config changes.
