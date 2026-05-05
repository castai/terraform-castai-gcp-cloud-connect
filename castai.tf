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

  ignore_all_server_changes = true

  # Full payload including the SA key — used only for the initial POST.
  # ignore_changes = [data] prevents the sensitive key from causing plan diffs.
  data = jsonencode({
    enabled  = var.integration_enabled
    name     = var.integration_name
    provider = "GCP"
    scope    = var.scope
    gcp_service_account_key = {
      key = base64decode(google_service_account_key.castai_cloud_connect.private_key)
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

  # Mutable fields only — used for PATCH updates. Changes here trigger plan diffs
  # without exposing the SA key.
  update_data = jsonencode({
    enabled = var.integration_enabled
    name    = var.integration_name
    settings = {
      commitments = {
        defaultStatus       = var.commitments_default_status
        assignAutomatically = var.commitments_auto_assignment
      }
    }
  })

  lifecycle {
    ignore_changes       = [data]
    replace_triggered_by = [google_service_account_key.castai_cloud_connect]
  }

  depends_on = [
    google_organization_iam_member.castai_cloud_connect,
    google_organization_iam_member.castai_custom_role,
    google_project_iam_member.castai_cloud_connect,
    google_project_iam_member.castai_custom_role,
    google_billing_account_iam_member.castai_cloud_connect,
    google_project_service.required,
  ]
}
