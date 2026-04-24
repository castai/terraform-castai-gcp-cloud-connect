# =============================================================================
# API Enablement
# =============================================================================

resource "google_project_service" "required" {
  for_each = local.all_project_api_pairs

  project = each.value.project
  service = each.value.service

  disable_on_destroy = false
}

# =============================================================================
# Service Account
# =============================================================================

resource "google_service_account" "castai_discovery" {
  account_id   = var.service_account_name
  display_name = "Cast AI Cloud Assets Discovery"
  project      = local.sa_project

  depends_on = [google_project_service.required]
}

resource "google_service_account_key" "castai_discovery" {
  service_account_id = google_service_account.castai_discovery.name
}

# =============================================================================
# Organization-level IAM Bindings (org-scoped mode)
# =============================================================================

resource "google_organization_iam_member" "castai_discovery" {
  for_each = local.org_role_bindings

  org_id = var.organization_id
  role   = each.value
  member = "serviceAccount:${google_service_account.castai_discovery.email}"
}

# =============================================================================
# Project-level IAM Bindings (project-scoped mode)
# =============================================================================

resource "google_project_iam_member" "castai_discovery" {
  for_each = local.project_role_bindings

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.castai_discovery.email}"
}

# =============================================================================
# Custom Roles (GCP_COMMITMENTS scope only)
# =============================================================================

resource "google_organization_iam_custom_role" "castai_discovery" {
  count = local.has_custom_role && local.is_org_scoped ? 1 : 0

  role_id     = var.custom_role_id
  org_id      = var.organization_id
  title       = "Cast AI Discovery - scope ${var.scope}"
  description = "Custom role for Cast AI to discover GCP resources - scope ${var.scope}"
  permissions = local.custom_role_org_permissions
}

resource "google_project_iam_custom_role" "castai_discovery" {
  count = local.has_custom_role && !local.is_org_scoped ? 1 : 0

  role_id     = var.custom_role_id
  project     = local.sa_project
  title       = "Cast AI Discovery - scope ${var.scope}"
  description = "Custom role for Cast AI to discover GCP resources - scope ${var.scope}"
  permissions = local.custom_role_project_permissions
}

# Bind the custom role at org level
resource "google_organization_iam_member" "castai_custom_role" {
  count = local.has_custom_role && local.is_org_scoped ? 1 : 0

  org_id = var.organization_id
  role   = google_organization_iam_custom_role.castai_discovery[0].id
  member = "serviceAccount:${google_service_account.castai_discovery.email}"
}

# Bind the custom role at project level (each project gets the binding)
resource "google_project_iam_member" "castai_custom_role" {
  for_each = local.custom_role_project_bindings

  project = each.value
  role    = google_project_iam_custom_role.castai_discovery[0].id
  member  = "serviceAccount:${google_service_account.castai_discovery.email}"
}

# =============================================================================
# Billing Account IAM Bindings (org-scoped only)
# =============================================================================

resource "google_billing_account_iam_member" "castai_discovery" {
  for_each = local.billing_bindings

  billing_account_id = each.value.billing_account_id
  role               = each.value.role
  member             = "serviceAccount:${google_service_account.castai_discovery.email}"
}
