---
name: Bug Report
about: Report a bug to help us improve the project
title: "[BUG] "
labels: bug
assignees: ''
---

## Describe the Bug

A clear and concise description of what the bug is.

## Module Affected

Which module is affected by this bug?

- [ ] modules/aws/network
- [ ] modules/aws/compute
- [ ] modules/aws/security
- [ ] modules/aws/monitoring
- [ ] modules/aws/dns
- [ ] modules/azure/network
- [ ] modules/azure/compute
- [ ] modules/azure/security
- [ ] modules/azure/monitoring
- [ ] modules/azure/dns
- [ ] modules/gcp/network
- [ ] modules/gcp/compute
- [ ] modules/gcp/security
- [ ] modules/gcp/monitoring
- [ ] modules/gcp/dns
- [ ] modules/cross-cloud/vpn
- [ ] modules/cross-cloud/logging
- [ ] Other (please specify)

## Environment

- **OS**: (e.g., Ubuntu 22.04, macOS 14)
- **Cloud Provider Account**: (e.g., AWS, Azure, GCP)
- **Region**: (e.g., us-east-1, westeurope, us-central1)

## Terraform Version

```
Paste the output of `terraform version` here.
```

## Provider Versions

```
Paste the relevant provider versions here.
```

## Expected Behavior

A clear and concise description of what you expected to happen.

## Steps to Reproduce

1. Configure the module with the following inputs:
   ```hcl
   # Paste your module configuration here
   ```
2. Run `terraform plan` or `terraform apply`.
3. Observe the error.

## Actual Behavior

What actually happened? Include any error messages or unexpected output.

```
Paste error output here.
```

## Additional Context

Add any other context about the problem here, such as screenshots, logs, or related issues.
