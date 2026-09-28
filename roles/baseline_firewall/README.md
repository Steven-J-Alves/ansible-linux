# baseline_firewall

## Purpose

Configures host-based firewall rules using UFW on Debian-family hosts and firewalld on RedHat-family hosts. Both backends are driven by the same port list variables, providing a single inventory-level interface regardless of distro. Port 22 is included in the default allow list; always verify the SSH port is present before running in production.

**LOCKOUT RISK:** If the SSH port is not in `baseline_firewall_allowed_tcp_ports`, you will lose access. Always run `--check` first.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_firewall_enabled` | bool | `true` | RECOMMENDED | Enable the firewall |
| `baseline_firewall_allowed_tcp_ports` | list | `[22, 443]` | ENVIRONMENT-DEPENDENT | TCP ports to open inbound |
| `baseline_firewall_allowed_udp_ports` | list | `[]` | ENVIRONMENT-DEPENDENT | UDP ports to open inbound |
| `baseline_firewall_default_input_policy` | string | `"deny"` | SECURITY-HARDENED | Default inbound policy |
| `baseline_firewall_default_output_policy` | string | `"allow"` | DEFAULT | Default outbound policy |

## Dependencies

- ansible-core >= 2.15
- Collections: `community.general` (UFW), `ansible.posix` (firewalld)

## Minimal usage

```yaml
- hosts: all
  become: true
  vars:
    baseline_firewall_allowed_tcp_ports:
      - 22
      - 80
      - 443
  roles:
    - baseline_firewall
```

## Rollback

On Debian: `ufw disable`. On RedHat: `systemctl stop firewalld && systemctl disable firewalld`. Re-run the role with `baseline_firewall_enabled: false` for a clean managed state.
