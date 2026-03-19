# AWS DNS Module

Manages AWS Route 53 DNS resources including hosted zones, DNS records, and health checks for reliable domain name resolution.

## Usage

```hcl
module "aws_dns" {
  source = "./modules/aws/dns"

  domain_name        = "example.com"
  create_hosted_zone = true
  records = [
    {
      name    = "app"
      type    = "A"
      ttl     = 300
      records = ["10.0.1.100"]
    },
    {
      name    = "api"
      type    = "CNAME"
      ttl     = 300
      records = ["app.example.com"]
    }
  ]
  enable_health_checks = true
  environment          = "production"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `domain_name` | The domain name for the hosted zone | `string` | n/a | yes |
| `create_hosted_zone` | Whether to create a new hosted zone | `bool` | `true` | no |
| `hosted_zone_id` | Existing hosted zone ID (if not creating a new one) | `string` | `null` | no |
| `records` | List of DNS record objects to create | `list(object)` | `[]` | no |
| `enable_health_checks` | Whether to create health checks for A records | `bool` | `false` | no |
| `health_check_path` | Path for HTTP health checks | `string` | `"/"` | no |
| `health_check_port` | Port for health checks | `number` | `443` | no |
| `health_check_type` | Type of health check (HTTP, HTTPS, TCP) | `string` | `"HTTPS"` | no |
| `environment` | Environment name for tagging | `string` | n/a | yes |
| `tags` | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `hosted_zone_id` | The ID of the Route 53 hosted zone |
| `hosted_zone_name_servers` | The name servers for the hosted zone |
| `record_fqdns` | List of fully qualified domain names for created records |
| `health_check_ids` | List of health check IDs |
