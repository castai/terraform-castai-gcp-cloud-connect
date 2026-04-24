# =============================================================================
# API Enablement
# =============================================================================

resource "google_project_service" "required" {
  for_each = var.enable_project_apis ? local.all_project_api_pairs : {}

  project = each.value.project
  service = each.value.service

  disable_on_destroy = false
}

# =============================================================================
# Service Account
# =============================================================================

resource "google_service_account" "castai_cloud_connect" {
  account_id   = var.service_account_name
  display_name = "Cast AI Cloud Connect"
  project      = local.sa_project

  depends_on = [google_project_service.required]
}

resource "google_service_account_key" "castai_cloud_connect" {
  service_account_id = google_service_account.castai_cloud_connect.name
}

# =============================================================================
# Organization-level IAM Bindings (org-scoped mode)
# =============================================================================

resource "google_organization_iam_member" "castai_cloud_connect" {
  for_each = local.org_role_bindings

  org_id = each.value.org_id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.castai_cloud_connect.email}"
}

# =============================================================================
# Project-level IAM Bindings (project-scoped mode)
# =============================================================================

resource "google_project_iam_member" "castai_cloud_connect" {
  for_each = local.project_role_bindings

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.castai_cloud_connect.email}"
}

# =============================================================================
# Custom Roles (GCP_COMMITMENTS scope only)
# =============================================================================

resource "google_organization_iam_custom_role" "castai_cloud_connect" {
  for_each = local.custom_role_org_bindings

  role_id     = var.custom_role_id
  org_id      = each.value
  title       = "Cast AI Cloud Connect - scope ${var.scope}"
  description = "Custom role for Cast AI Cloud Connect - scope ${var.scope}"
  permissions = local.custom_role_org_permissions
}

resource "google_project_iam_custom_role" "castai_cloud_connect" {
  count = local.has_custom_role && !local.is_org_scoped ? 1 : 0

  role_id     = var.custom_role_id
  project     = local.sa_project
  title       = "Cast AI Cloud Connect - scope ${var.scope}"
  description = "Custom role for Cast AI Cloud Connect - scope ${var.scope}"
  permissions = local.custom_role_project_permissions
}

# Bind the custom role at org level (one binding per org)
resource "google_organization_iam_member" "castai_custom_role" {
  for_each = local.custom_role_org_bindings

  org_id = each.value
  role   = google_organization_iam_custom_role.castai_cloud_connect[each.key].id
  member = "serviceAccount:${google_service_account.castai_cloud_connect.email}"
}

# Bind the custom role at project level (each project gets the binding)
resource "google_project_iam_member" "castai_custom_role" {
  for_each = local.custom_role_project_bindings

  project = each.value
  role    = google_project_iam_custom_role.castai_cloud_connect[0].id
  member  = "serviceAccount:${google_service_account.castai_cloud_connect.email}"
}

# =============================================================================
# Billing Account IAM Bindings (org-scoped only)
# =============================================================================

resource "google_billing_account_iam_member" "castai_cloud_connect" {
  for_each = local.billing_bindings

  billing_account_id = each.value.billing_account_id
  role               = each.value.role
  member             = "serviceAccount:${google_service_account.castai_cloud_connect.email}"
}
