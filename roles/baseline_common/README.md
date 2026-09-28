# baseline_common

## Purpose

Bootstraps every managed host with a consistent identity: hostname, timezone, locale, MOTD, and the base package set that all other roles can assume is present.

## Inputs

| Name | Type | Default | Category | Description |
|---|---|---|---|---|
| `baseline_common_hostname` | string | `""` | ENVIRONMENT-DEPENDENT | System hostname. Empty string = keep cloud-init value. |
| `baseline_common_timezone` | string | `"UTC"` | RECOMMENDED | Any tz identifier from `timedatectl list-timezones`. |
| `baseline_common_locale` | string | `"en_US.UTF-8"` | RECOMMENDED | System locale. Debian: locale.gen + /etc/default/locale. RedHat: /etc/locale.conf + langpack. |
| `baseline_common_locale_package_redhat` | string | `"glibc-langpack-en"` | DEFAULT | Langpack installed on RedHat hosts. Override for non-English locales. |
| `baseline_common_motd_enabled` | bool | `true` | RECOMMENDED | Set `false` to leave MOTD to the provisioner. |
| `baseline_common_motd_message` | string | see defaults | ENVIRONMENT-DEPENDENT | Content written to `/etc/motd`. |
| `baseline_common_packages` | list | `[curl, wget, vim, htop, unzip, ca-certificates]` | RECOMMENDED | Packages installed on every host. Cross-family safe. |
| `baseline_common_extra_packages` | list | `[]` | ENVIRONMENT-DEPENDENT | Additional packages per environment or host_vars. |

## Dependencies

- ansible-core >= 2.15
- Collections: `community.general` (for the `timezone` module)

## Minimal usage

```yaml
- hosts: all
  become: true
  roles:
    - baseline_common
```

## Environment-specific override example

```yaml
# inventories/production/host_vars/web01.yml
baseline_common_hostname: web01.kriolu-kloud.cv
baseline_common_timezone: Atlantic/Cape_Verde
baseline_common_motd_message: |
  PRODUCTION — kriolu-kloud.cv
  Managed by Ansible. Unauthorised access is prohibited.
baseline_common_extra_packages:
  - jq
  - rsync
```

## Rollback

See the `baseline_common` section in `docs/rollback-procedures.md`.
