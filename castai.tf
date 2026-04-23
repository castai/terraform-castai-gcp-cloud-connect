provider "restapi" {
  uri                  = var.castai_api_url
  write_returns_object = true

  headers = {
    "Content-Type" = "application/json"
    "X-API-Key"    = var.castai_api_key
  }
}

resource "restapi_object" "castai_integration" {
  path = "/inventory/v1beta/organizations/${var.castai_organization_id}/cloud-asset-integrations"

  data = jsonencode({
    enabled  = true
    name     = var.integration_name
    provider = "GCP"
    scope    = var.scope
    gcp_service_account_key = {
      key = base64decode(google_service_account_key.castai_discovery.private_key)
    }
    metadata = {
      expectedProjectCount = local.expected_project_count
    }
    settings = {
      commitments = {
        defaultStatus  = var.commitments_default_status
        autoAssignment = var.commitments_auto_assignment
      }
    }
  })

  depends_on = [
    google_organization_iam_member.castai_discovery,
    google_organization_iam_member.castai_custom_role,
    google_project_iam_member.castai_discovery,
    google_project_iam_member.castai_custom_role,
    google_billing_account_iam_member.castai_discovery,
    google_project_service.required,
  ]
}
