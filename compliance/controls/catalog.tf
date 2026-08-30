# ------------------------------------------------------------------------------
# Control catalog
#
# Maps each control this landing zone claims to the bounded context that
# implements it and the contract output that evidences it. The catalog is data,
# not enforcement: enforcement lives in compliance/policies (plan-time, rego)
# and in the preconditions inside each context.
#
# The point of keeping it here rather than in a spreadsheet is that a contract
# output named below either exists or the plan fails, so the matrix cannot
# drift away from the code without someone noticing.
# ------------------------------------------------------------------------------

locals {
  controls = {
    "NET-01" = {
      statement = "All networks emit flow logs."
      context   = "networking"
      evidence  = "flow_logs_enabled"
      severity  = "high"
      frameworks = {
        cis      = "CIS 3.9 / 6.5 (VPC flow logs, NSG flow logs)"
        iso27001 = "A.8.15 Logging, A.8.16 Monitoring activities"
        soc2     = "CC7.2 System monitoring"
        nis2     = "Art. 21(2)(b) Incident handling"
      }
    }

    "NET-02" = {
      statement = "Workloads are segmented into web, app and data tiers."
      context   = "networking"
      evidence  = "networks[*].subnets"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x Networking"
        iso27001 = "A.8.22 Segregation of networks"
        soc2     = "CC6.6 Logical access — boundary protection"
        nis2     = "Art. 21(2)(d) Supply chain and network security"
      }
    }

    "NET-03" = {
      statement = "Traffic between clouds is encrypted in transit."
      context   = "networking"
      evidence  = "cross_cloud_connected"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.7 Transmission of data"
        nis2     = "Art. 21(2)(h) Cryptography"
      }
    }

    "IAM-01" = {
      statement = "Compute runs under an explicit workload identity; no static credentials."
      context   = "access-control"
      evidence  = "workload_identity"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 1.x Identity and Access Management"
        iso27001 = "A.5.16 Identity management, A.5.17 Authentication information"
        soc2     = "CC6.1 Logical access — credentials"
        nis2     = "Art. 21(2)(i) Access control"
      }
    }

    "IAM-02" = {
      statement = "Public ingress is declared explicitly and reviewable."
      context   = "access-control"
      evidence  = "public_ingress_cidrs"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x Network exposure"
        iso27001 = "A.8.20 Network security"
        soc2     = "CC6.6"
        nis2     = "Art. 21(2)(e)"
      }
    }

    "IAM-03" = {
      statement = "Secrets are held in a managed store, never in configuration."
      context   = "access-control"
      evidence  = "secret_store"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 1.x"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.1"
        nis2     = "Art. 21(2)(h)"
      }
    }

    "APP-01" = {
      statement = "Production endpoints terminate TLS."
      context   = "workload-hosting"
      evidence  = "tls_enabled"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 4.x"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.7 Transmission of data"
        nis2     = "Art. 21(2)(h) Cryptography"
      }
    }

    "APP-02" = {
      statement = "Workloads run with redundant capacity (minimum two instances)."
      context   = "workload-hosting"
      evidence  = "capacity"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.14 Redundancy of information processing facilities"
        soc2     = "A1.2 Availability — recovery"
        nis2     = "Art. 21(2)(c) Business continuity"
      }
    }

    "LOG-01" = {
      statement = "Logs are retained at least 90 days, and 365 in production."
      context   = "observability"
      evidence  = "retention_days"
      severity  = "high"
      frameworks = {
        cis      = "CIS 3.x Logging"
        iso27001 = "A.8.15 Logging"
        soc2     = "CC7.2 System monitoring"
        nis2     = "Art. 21(2)(b) Incident handling"
      }
    }

    "LOG-02" = {
      statement = "Alarms are delivered to an accountable recipient."
      context   = "observability"
      evidence  = "alert_channels"
      severity  = "high"
      frameworks = {
        cis      = "CIS 3.x / 4.x Monitoring and alerting"
        iso27001 = "A.8.16 Monitoring activities"
        soc2     = "CC7.3 Evaluation of security events"
        nis2     = "Art. 21(2)(b), Art. 23 Reporting obligations"
      }
    }

    "TAG-01" = {
      statement = "Every resource carries owner, cost centre and data classification."
      context   = "platform/tagging"
      evidence  = "mandatory_keys"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.5.9 Inventory of information and other associated assets"
        soc2     = "CC3.2 Risk identification"
        nis2     = "Art. 21(2)(a) Risk analysis"
      }
    }
  }

  frameworks = ["cis", "iso27001", "soc2", "nis2"]
}
