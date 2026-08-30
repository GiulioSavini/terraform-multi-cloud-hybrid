# terraform-multi-cloud-hybrid

A hybrid landing zone across AWS, Azure and GCP, organised as **bounded
contexts** rather than as a pile of provider modules.

[![CI](https://github.com/GiulioSavini/terraform-multi-cloud-hybrid/actions/workflows/ci.yml/badge.svg)](https://github.com/GiulioSavini/terraform-multi-cloud-hybrid/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Why it is laid out this way

Most multi-cloud Terraform is organised by provider — `modules/aws/network`,
`modules/azure/network`, `modules/gcp/network`. That arrangement makes the
cloud vendor the primary axis and the problem being solved a secondary one, so
a change to "how networking works here" is spread across three trees, and every
consumer has to branch per provider.

Here the **domain is the axis** and the provider is an implementation detail:

```
domains/<context>/
    contract.tf      the public interface and its invariants
    variables.tf     what the context needs, in domain terms
    outputs.tf       what the context publishes — the same shape for every cloud
    README.md        the invariants, written down
    aws/ azure/ gcp/ adapters, private to the context
```

A consumer reads `outputs.tf`. It never reaches into `aws/`, `azure/` or
`gcp/`, and `scripts/check-boundaries.sh` fails CI if it tries.

### The contexts

| Context | Owns |
|---|---|
| [`networking`](domains/networking) | Address space, subnet tiers, cross-cloud connectivity |
| [`access-control`](domains/access-control) | Network perimeter and workload identity |
| [`workload-hosting`](domains/workload-hosting) | Load balancers, autoscaling, the images they run |
| [`service-discovery`](domains/service-discovery) | Public DNS records and private zones |
| [`observability`](domains/observability) | Metrics, alarms, log retention, central archive |

### The other layers

```
platform/       shared kernel — naming and tagging, used by every context
compliance/     control catalog and the rego policies that enforce it
applications/   composition root — the only place contexts are wired together
deployments/    one directory per environment: backend, providers, tfvars
```

## Uniform contracts

Every context publishes the same shape whichever clouds are enabled, so a
consumer writes one expression instead of three branches:

```hcl
networks = {
  aws = {
    id      = "vpc-0abc..."
    cidr    = "10.0.0.0/16"
    subnets = { web = [...], app = [...], data = [...] }
  }
}
```

Subnet ids are always lists — AWS spreads a tier across availability zones,
Azure and GCP return one subnet and are wrapped to match.

The same idea drives `capacity`: AWS calls it `desired_capacity`, Azure calls it
`instances`, GCP calls it replicas. The domain has one concept, validated once
(`min <= desired <= max`, and `min >= 2`).

## Compliance

Controls are declared in [`compliance/controls`](compliance/controls) and mapped
to **CIS Benchmarks, ISO 27001 Annex A, SOC 2 TSC and NIS2**. Each control names
the context that implements it and the contract output that evidences it, so the
matrix cannot drift away from the code without the plan failing.

Enforcement happens in two places:

- **Plan time, in the contexts.** Preconditions reject configurations that would
  apply cleanly and not work: overlapping address space, alarms with no
  recipient, production without TLS, flow logs with no destination.
- **Plan time, in policy.** [`compliance/policies`](compliance/policies) holds
  rego evaluated by conftest against the plan JSON. The policies have their own
  unit tests — `conftest verify --policy compliance/policies` — and CI runs them.

`terraform output compliance_evidence` returns the control values read from the
contracts, ready to attach to an audit response.

## Usage

```bash
cd deployments/dev
cp terraform.tfvars.example terraform.tfvars   # then edit
terraform init
terraform plan -out=plan.tfplan

# Check the plan against policy before applying
terraform show -json plan.tfplan > plan.json
conftest test --policy ../../compliance/policies plan.json

terraform apply plan.tfplan
```

Deployments differ deliberately: `dev` is AWS-only with 90-day retention, `stg`
adds Azure, `prd` spans all three with cross-cloud tunnels, central logging and
365-day retention.

## What this repository is not

It is a **reference landing zone**, not a product. It has never been applied
against a billing account by its author — every check below is static: format,
validate, lint, policy unit tests, misconfiguration scanning. Nothing here has
been proven against live cloud APIs, and applying it will cost money.

Read `deployments/prd/main.tf` before running anything.

## CI

`fmt`, `validate` across all twelve roots, context boundaries, policy unit
tests, `tflint` and a Trivy config scan. Every job can fail the build; findings
are fixed or suppressed in `.trivyignore` with a written reason, never hidden
behind `continue-on-error`.

## License

MIT — see [LICENSE](LICENSE).
