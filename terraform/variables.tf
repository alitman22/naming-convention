variable "service_name" {
  description = "Canonical service name: [environment]-[region]-[domain]-[component]-[resource_type]-[instance]"
  type        = string

  validation {
    # Use can(regex(...)) so invalid names fail cleanly during terraform plan.
    condition = can(regex(
      "^[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[0-9]{2}$",
      var.service_name
    ))

    error_message = "service_name must follow [environment]-[region]-[domain]-[component]-[resource_type]-[instance], for example: prod-usw2-core-auth-api-01"
  }
}
