# Bounded context: service-discovery

Owns how a workload is found: public DNS records and private zones.

## Invariants

1. **Records follow deployments.** A cloud in scope must have an entry in the
   `endpoints` contract; this context cannot publish a name for a workload
   that was not deployed.
2. **This context never inspects compute.** It reads addresses from the
   workload-hosting contract, not from load balancer resources directly.
3. **Public and private zones are separate outputs.** Binding an internal name
   into a public zone is the failure this separation exists to prevent.

## Contract

`fqdns` is what an application consumes. `public_zones` exposes delegation name
servers for whoever owns the registrar; `private_zones` covers internal
resolution only.
