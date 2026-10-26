provider "restapi" {
  uri                   = var.castai_api_url
  write_returns_object  = false
  create_returns_object = true

  headers = {
    "Content-Type" = "application/json"
    "X-API-Key"    = var.castai_api_key
  }
}

locals {
  integration_path = "/inventory/v1beta/organizations/${var.castai_organization_id}/cloud-asset-integrations"
}

resource "restapi_object" "castai_integration" {
  path = local.integration_path

  update_method = "PATCH"

  # Full payload — used only for the initial POST. The Cast AI identity SA email
  # comes from the onboarding config; no key material is involved.
  # ignore_changes = [data] keeps the integration from being re-created on
  # unrelated payload drift.
  data = jsonencode({
    enabled  = var.integration_enabled
    name     = var.integration_name
    provider = "GCP"
    scope    = var.scope
    gcp_impersonation_credentials = {
      target_service_account     = google_service_account.castai_cloud_connect.email
      cast_service_account_email = local.cast_identity_sa_email
    }
    metadata = {
      expectedProjectCount = local.expected_project_count
    }
    settings = {
      commitments = {
        defaultStatus       = var.commitments_default_status
        assignAutomatically = var.commitments_auto_assignment
      }
    }
  })

  # Mutable fields only — used for PATCH updates. The credentials are included
  # so that upgrading from an older module version PATCHes a legacy key-based
  # integration over to impersonation in place (no re-create, stable
  # integration_id). Requires a Cast AI API with credential-update support.
  update_data = jsonencode({
    enabled = var.integration_enabled
    name    = var.integration_name
    gcp_impersonation_credentials = {
      target_service_account     = google_service_account.castai_cloud_connect.email
      cast_service_account_email = local.cast_identity_sa_email
    }
    settings = {
      commitments = {
        defaultStatus       = var.commitments_default_status
        assignAutomatically = var.commitments_auto_assignment
      }
    }
  })

  lifecycle {
    # The API does not echo credentials in its responses — ignoring data
    # prevents perpetual plan diffs against the response body.
    ignore_changes = [data]
  }

  depends_on = [
    google_organization_iam_member.castai_cloud_connect,
    google_organization_iam_member.castai_custom_role,
    google_project_iam_member.castai_cloud_connect,
    google_project_iam_member.castai_custom_role,
    google_billing_account_iam_member.castai_cloud_connect,
    google_service_account_iam_member.castai_identity_token_creator,
    google_project_service.required,
  ]
}
