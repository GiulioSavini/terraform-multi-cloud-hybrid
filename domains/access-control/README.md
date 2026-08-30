# Bounded context: access-control

Owns who and what may reach a workload: the network perimeter (security groups,
NSG rules, Cloud Armor policies) and workload identity (instance profiles,
managed identities, service accounts).

## Invariants

1. **This context never creates networks.** It attaches to the fabric published
   by `domains/networking`. A cloud in scope here must exist in that fabric.
2. **Identity is issued here, bound elsewhere.** `workload_identity` is
   consumed only by `domains/workload-hosting`. No other context should assume
   these roles.
3. **Public ingress is explicit.** `alb_ingress_cidrs` defaults to the internet
   because a public load balancer is public by design, but the value is
   published in the contract so policy can assert on it.
4. **The data tier gets no workload identity.** Key Vault access is granted to
   the web and app tiers only; the data tier runs no compute in this landing
   zone.

## Contract

Consume `outputs.tf`. Do not reference `./aws`, `./azure` or `./gcp` directly.

## Compliance

| Control | Framework | Evidence |
|---|---|---|
| No standing credentials on compute | CIS 1.x, ISO 27001 A.5.16, SOC 2 CC6.1 | `workload_identity` — role assumption only, no access keys |
| Least-privilege network exposure | CIS 5.x, ISO 27001 A.8.20, NIS2 | `public_ingress_cidrs` |
| Secrets held in a managed store | ISO 27001 A.8.24, SOC 2 CC6.1 | `secret_store` |
