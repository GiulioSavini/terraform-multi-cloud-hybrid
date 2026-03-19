# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- AWS networking module with VPC, subnets, internet gateway, NAT gateway, and route tables.
- AWS compute module with EC2 instances, auto scaling groups, and launch templates.
- AWS security module with IAM roles, policies, security groups, and KMS keys.
- AWS monitoring module with CloudWatch alarms, dashboards, log groups, and SNS topics.
- AWS DNS module with Route 53 hosted zones, records, and health checks.
- Azure networking module with virtual networks, subnets, network security groups, and load balancers.
- Azure compute module with virtual machines, VM scale sets, and availability sets.
- Azure security module with Azure AD roles, Key Vault, and managed identities.
- Azure monitoring module with Azure Monitor alerts, Log Analytics workspaces, and diagnostic settings.
- Azure DNS module with Azure DNS zones, records, and private DNS zones.
- GCP networking module with VPC networks, subnets, firewall rules, and Cloud NAT.
- GCP compute module with Compute Engine instances, instance groups, and instance templates.
- GCP security module with IAM bindings, service accounts, and Cloud KMS.
- GCP monitoring module with Cloud Monitoring alert policies, dashboards, and log sinks.
- GCP DNS module with Cloud DNS managed zones and record sets.
- Cross-cloud VPN module for site-to-site connectivity between AWS, Azure, and GCP.
- Cross-cloud logging module for centralized log aggregation across cloud providers.
- Pre-commit hooks configuration with terraform fmt, validate, tflint, and tfsec.
- CI/CD pipeline with GitHub Actions for automated validation and deployment.
- Comprehensive documentation for all modules with usage examples.
- TFLint configuration with AWS, Azure, and GCP plugins.
- Security scanning with tfsec and detect-secrets integration.

[1.0.0]: https://github.com/GiulioSavini/terraform-multi-cloud-hybrid/releases/tag/v1.0.0
