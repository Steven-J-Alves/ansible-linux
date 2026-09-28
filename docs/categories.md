# Configuration categories

Every parameter set by a role in this project belongs to exactly one of these five boxes. Classifying a parameter forces the team to answer *why* it changes from the distro default — and stops the "let's copy this from a CIS PDF" habit.

## DEFAULT
What the distro ships. Documented for completeness, never changed by the role.

## RECOMMENDED
Community/vendor/CIS-recommended change with mild trade-off. The team accepts the trade-off because the benefit is clear (e.g. `PermitRootLogin no` in sshd_config).

## ENVIRONMENT-DEPENDENT
Varies by environment or by host role. Example: `PasswordAuthentication yes` in dev, `no` in production. The role reads the value from `group_vars/<env>/all.yml`.

## SECURITY-HARDENED
Parameter with clear security impact where operational cost is accepted. Example: disabling `kernel.modules_disabled=1` after boot — breaks live `modprobe`, but stops runtime module injection.

## PERFORMANCE-TUNED
Parameter with an associated performance metric, measured before and after the change. Never set without evidence. Example: `vm.swappiness=10` on a DB host — measured impact on iowait during peak.

---

## How to classify

For each variable in a role's `defaults/main.yml`, add a comment above it that names the category:

```yaml
# SSH listening port. SECURITY-HARDENED. Changing from 22 breaks port scanners
# but adds ~zero real security unless combined with fail2ban rate-limiting.
baseline_ssh_port: 22
```
