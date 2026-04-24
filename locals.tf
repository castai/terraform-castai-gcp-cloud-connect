locals {
  is_org_scoped = var.organization_id != ""
  sa_project    = coalesce(var.project_id, try(data.google_project.default[0].project_id, null))

  discovered_project_ids = try([for p in data.google_projects.all[0].projects : p.project_id], [])

  # When project_ids is empty, discover all active projects visible to the caller.
  # SA project is always included.
  all_project_ids = distinct(concat(
    [local.sa_project],
    length(var.project_ids) > 0 ? var.project_ids : local.discovered_project_ids,
  ))

  # Roles from API
  org_roles     = try(local.onboarding_config.gcpConfig.organizationRoles, [])
  project_roles = try(local.onboarding_config.gcpConfig.projectRoles, [])

  # Custom role permissions from API (only for GCP_COMMITMENTS scope)
  custom_role_org_permissions     = try(local.onboarding_config.gcpConfig.customRoleOrgPermissions, [])
  custom_role_project_permissions = try(local.onboarding_config.gcpConfig.customRoleProjectPermissions, [])
  has_custom_role                 = length(local.custom_role_org_permissions) > 0 || length(local.custom_role_project_permissions) > 0

  # API enablement: SA project gets all 4 APIs, other projects get 2
  sa_project_apis = toset([
    "compute.googleapis.com",
    "cloudcommerceconsumerprocurement.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  other_project_apis = toset([
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  other_project_ids = [for p in local.all_project_ids : p if p != local.sa_project]

  all_project_api_pairs = merge(
    {
      for api in local.sa_project_apis :
      "${local.sa_project}/${api}" => {
        project = local.sa_project
        service = api
      }
    },
    {
      for pair in setproduct(local.other_project_ids, local.other_project_apis) :
      "${pair[0]}/${pair[1]}" => {
        project = pair[0]
        service = pair[1]
      }
    }
  )

  # Org-level role bindings (org-scoped mode only)
  org_role_bindings = local.is_org_scoped ? {
    for role in local.org_roles :
    role => role
  } : {}

  # Project-level role bindings (project-scoped mode only)
  project_role_bindings = !local.is_org_scoped ? {
    for pair in setproduct(local.all_project_ids, local.project_roles) :
    "${pair[0]}/${pair[1]}" => {
      project = pair[0]
      role    = pair[1]
    }
  } : {}

  # Custom role project bindings (project-scoped mode with custom roles)
  custom_role_project_bindings = local.has_custom_role && !local.is_org_scoped ? toset(local.all_project_ids) : toset([])

  # Billing account bindings (org-scoped only)
  billing_roles = toset([
    "roles/billing.viewer",
    "roles/consumerprocurement.orderViewer",
  ])

  billing_bindings = local.is_org_scoped ? {
    for pair in setproduct(var.billing_account_ids, local.billing_roles) :
    "${pair[0]}/${pair[1]}" => {
      billing_account_id = pair[0]
      role               = pair[1]
    }
  } : {}

  expected_project_count = length(local.all_project_ids)
}
