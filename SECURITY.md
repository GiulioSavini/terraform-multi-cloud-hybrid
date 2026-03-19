# Security Policy

## Supported Versions

The following versions of this project are currently supported with security updates:

| Version | Supported          |
|---------|--------------------|
| 1.0.x   | Yes                |
| < 1.0   | No                 |

## Reporting a Vulnerability

We take the security of this project seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, send an email to:

**security@example.com**

Include the following information in your report:

- A description of the vulnerability.
- Steps to reproduce the issue.
- The affected module(s) or component(s).
- The potential impact of the vulnerability.
- Any suggested remediation, if applicable.

### Response Timeline

| Action                     | Timeframe         |
|----------------------------|--------------------|
| Acknowledgment of report   | Within 48 hours    |
| Initial assessment         | Within 72 hours    |
| Fix plan communicated      | Within 7 days      |
| Patch release              | As soon as possible, based on severity |

We will keep you informed of our progress throughout the process.

### Disclosure Policy

- We request that you give us reasonable time to address the vulnerability before making any public disclosure.
- We will coordinate with you on the timing of any public announcement.
- Credit will be given to the reporter in the release notes, unless anonymity is requested.

## Security Best Practices

### No Hard-Coded Secrets Policy

This project enforces a strict **no hard-coded secrets** policy. The following must never be committed to the repository:

- API keys, tokens, or credentials.
- Passwords or connection strings.
- Private keys or certificates.
- Cloud provider access keys or secret keys.
- Any other sensitive or personally identifiable information.

### How Secrets Are Managed

- Use Terraform variables with sensitive flags for secret values.
- Use cloud-native secret management services (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).
- Use environment variables or CI/CD secret injection for automation.
- Pre-commit hooks with `detect-secrets` are enforced to prevent accidental commits of sensitive data.

### Security Scanning

This project uses the following tools to maintain security:

- **tfsec** - Static analysis of Terraform code for security misconfigurations.
- **detect-secrets** - Pre-commit hook to prevent secrets from being committed.
- **Dependabot** - Automated dependency updates for known vulnerabilities.

## Contact

For security-related questions that are not vulnerability reports, open a GitHub discussion or contact security@example.com.
