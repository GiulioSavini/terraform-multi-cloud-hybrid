# Bounded context: workload-hosting

Owns the compute that serves the application: load balancers, autoscaling
groups, and the images they run.

## Invariants

1. **This context creates no networks and no identities.** It consumes the
   fabric from `domains/networking` and the identity and perimeter from
   `domains/access-control`.
2. **Capacity is one concept.** `min <= desired <= max`, and `min >= 2` — a
   single instance behind a load balancer has no availability story.
3. **Every instance runs under an explicit identity.** A cloud in scope
   without a `workload_identity` entry fails at plan time rather than falling
   back to an implicit role.
4. **Production terminates TLS.** In `prd`, an AWS deployment without an ACM
   certificate is rejected.

## Contract

`endpoints` carries addresses, `workload_refs` carries monitoring handles. They
are deliberately separate so a consumer cannot route traffic to a metric
dimension.

Instance sizing is per cloud on purpose: there is no portable vocabulary for
machine sizes, and inventing one would hide the cost differences between
providers rather than resolve them.

## Compliance

| Control | Framework | Evidence |
|---|---|---|
| Encryption in transit for public endpoints | ISO 27001 A.8.24, SOC 2 CC6.7, NIS2 | `tls_enabled` |
| Redundant capacity | SOC 2 A1.2, ISO 27001 A.8.14 | `capacity` |
| No standing credentials on compute | CIS 1.x, SOC 2 CC6.1 | identity bound from access-control |
