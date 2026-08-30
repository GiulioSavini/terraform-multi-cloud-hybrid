# Bounded context: observability

Owns detection: metrics, alarms, log retention, and optionally a cross-cloud
log archive.

## Invariants

1. **Alarms attach to published handles.** This context reads `workload_refs`
   from workload-hosting and never touches compute resources directly.
2. **Alarms must have a destination.** `alarm_email` is mandatory and
   validated; a landing zone whose alarms go nowhere provides no detection.
3. **Retention floor is 90 days, and 365 in production.** Shorter retention
   leaves no evidence for an incident discovered after the fact.
4. **Central logging needs both Azure and GCP.** With fewer sources the
   archive is an empty shell, so it fails at plan time instead.

## Compliance

| Control | Framework | Evidence |
|---|---|---|
| Log retention sufficient for incident investigation | ISO 27001 A.8.15, SOC 2 CC7.2, NIS2 Art. 21 | `retention_days` |
| Alerting reaches an accountable recipient | SOC 2 CC7.3, NIS2 incident handling | `alert_channels` |
| Centralised, tamper-evident log archive | CIS 3.x, ISO 27001 A.8.15 | `central_archive` |
