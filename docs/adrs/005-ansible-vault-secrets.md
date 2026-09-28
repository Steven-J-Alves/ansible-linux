---
adr_number: "005"
status: accepted
created: 2026-09-28
supersedes: ""
superseded_by: ""
---

# ADR 005: Ansible Vault for secrets management

## Context

The baseline roles will manage SSH keys, sudo passwords, user credentials, and potentially
API tokens for external services (e.g. node_exporter authentication). These values must be
stored encrypted in the repository — committing plaintext secrets is never acceptable.

The project is currently solo (one operator) with a single production VPS. The secrets
surface is small: a handful of variables per environment.

## Alternatives Considered

- **Ansible Vault** — built-in encryption for variables and files. Zero extra tooling:
  `ansible-vault encrypt_string` produces an inline encrypted value; `ansible-playbook`
  decrypts transparently with `--vault-password-file` or `--ask-vault-pass`. Portable
  across any machine with Ansible installed.

- **SOPS + age** — file-level encryption with per-key access control. Excellent for teams
  where different operators need different secret access. Requires `sops` and `age` binaries
  plus a key management step before any operator can decrypt. Overhead is justified at team
  scale; for a solo project it is friction without benefit.

- **HashiCorp Vault** — centralised secrets server with dynamic credentials, fine-grained
  ACLs, and audit logs. Correct choice for production SaaS with rotating credentials.
  Requires running and maintaining a Vault cluster — overkill for the current context.

- **Hardcoded plaintext** — not considered. Non-negotiable: no secrets in plaintext.

## Decision

**Ansible Vault for all sensitive values.**

Sensitive variables are encrypted inline with `ansible-vault encrypt_string` and committed
as part of the inventory `group_vars`. The vault password is stored outside the repo
(local file or password manager). No plaintext secrets in any tracked file.

SOPS + age is documented as the upgrade path when the project grows to multiple operators
with different access levels.

## Consequences

- **Positive:** zero extra tooling; works on any machine with Ansible; inline encrypted
  strings are diff-friendly in git (the ciphertext changes when the value changes, which
  is visible without decrypting).
- **Negative:** vault password rotation requires re-encrypting all secrets; no per-variable
  access control (it is all-or-nothing per vault password); does not support dynamic or
  short-lived credentials.
- **Neutral / accepted trade-offs:** one vault password per environment (dev/staging/production)
  is the recommended pattern — avoids dev vault password reaching production. This is a
  convention, not enforced by tooling.
