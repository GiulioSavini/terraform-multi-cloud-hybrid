# workload-hosting / azure adapter

**This is a private adapter of the `workload-hosting` bounded context. Do not source it
directly.**

It exists to translate the `workload-hosting` contract into azure resources, and its
interface tracks the azure provider rather than the domain — it will change
when the provider does, without a major version bump, because nothing outside
the context is supposed to depend on it.

Consume [`domains/workload-hosting`](../) instead. Its `outputs.tf` publishes the same
shape for every cloud, and `scripts/check-boundaries.sh` fails CI if this
directory is sourced from outside its own context.

If you need something this adapter exposes and the contract does not, add it to
the contract.
