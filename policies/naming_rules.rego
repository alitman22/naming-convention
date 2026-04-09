package naming

# Canonical naming pattern:
# [environment]-[region]-[domain]-[component]-[resource_type]-[instance]
required_pattern := "^[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+-[0-9]{2}$"
required_format := "[environment]-[region]-[domain]-[component]-[resource_type]-[instance]"
example_name := "prod-usw2-billing-api-vm-01"

# Generic helper used by both Kubernetes and Terraform checks.
valid_name(name) {
  regex.match(required_pattern, name)
}

# Deny non-compliant Kubernetes resource names (for example, Deployment manifests).
deny[msg] {
  input.kind
  input.metadata.name

  name := input.metadata.name
  not valid_name(name)

  msg := sprintf(
    "Invalid Kubernetes resource name %q. Required format: %s. Example: %s.",
    [name, required_format, example_name],
  )
}

# Deny non-compliant Terraform plan resource names for any create action.
deny[msg] {
  input.resource_changes

  rc := input.resource_changes[_]
  is_create_action(rc)
  name := terraform_resource_name(rc)
  name != ""
  not valid_name(name)

  msg := sprintf(
    "Invalid Terraform resource name %q at %q. Required format: %s. Example: %s.",
    [name, rc.address, required_format, example_name],
  )
}

# Treat both pure create and replace operations (which include a create step) as create actions.
is_create_action(rc) {
  actions := rc.change.actions
  actions[_] == "create"
}

# Resolve a Terraform resource name from common plan shapes.
# 1) Most resources expose change.after.name
terraform_resource_name(rc) = name {
  name := rc.change.after.name
}

# 2) Some resources expose a Name tag instead of name.
terraform_resource_name(rc) = name {
  name := rc.change.after.tags.Name
}

# 3) Some nested providers emit values.name in the JSON plan structure.
terraform_resource_name(rc) = name {
  name := rc.change.after.values.name
}

# 4) If no name-like field exists, skip this specific resource.
terraform_resource_name(rc) = "" {
  not rc.change.after.name
  not rc.change.after.tags.Name
  not rc.change.after.values.name
}
