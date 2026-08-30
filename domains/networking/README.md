# Bounded context: networking

Owns the network fabric of the landing zone: address space, subnet tiers, and
connectivity between clouds.

## Invariants

These hold for every deployment of this context. Each is enforced by a
precondition in `contract.tf`, so a violation fails at plan time rather than
producing infrastructure that applies cleanly and does not work.

1. **Address ranges do not overlap.** The cross-cloud tunnels route between
   them; overlapping ranges blackhole traffic at runtime with no build error.
2. **Every enabled cloud has placement.** A cloud listed in `clouds` without a
   matching `placement` entry cannot be scheduled.
3. **Cross-cloud connectivity requires both AWS and Azure.** The tunnel pair
   has no other endpoints in this landing zone.
4. **A shared key of at least 20 characters** when tunnels are enabled.
5. **Azure flow logs need a storage account.** Enabled flow logs without a
   destination silently discard the evidence.

## Contract

Consume `outputs.tf`. Do **not** reference `./aws`, `./azure` or `./gcp` from
outside this directory — those are adapters, and their interfaces track the
provider rather than the domain. If you need something they expose and the
contract does not, add it to the contract.

The `networks` output has the same shape whichever clouds are enabled:

```hcl
networks = {
  aws = {
    id      = "vpc-0abc..."
    cidr    = "10.0.0.0/16"
    subnets = { web = [...], app = [...], data = [...] }
  }
}
```

Subnet ids are always lists. AWS spreads each tier across availability zones;
Azure and GCP return a single subnet per tier and are wrapped to match, so a
consumer never branches on provider.

## Compliance

| Control | Framework | Evidence |
|---|---|---|
| Flow logging enabled on all networks | CIS 3.x, ISO 27001 A.8.15/A.8.16, NIS2 detection | `flow_logs_enabled` output |
| Network segmentation into web/app/data tiers | CIS, ISO 27001 A.8.22, SOC 2 CC6.6 | `networks[*].subnets` |
| Cross-cloud traffic encrypted in transit | ISO 27001 A.8.24, SOC 2 CC6.7, NIS2 | `cross_cloud_connected` output |

Exceptions must be recorded in `compliance/controls`, not by flipping a default.
