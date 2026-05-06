output "service_account_email" {
  description = "Email of the GCP service account created for Cast AI"
  value       = google_service_account.castai_cloud_connect.email
}

output "service_account_id" {
  description = "Fully qualified ID of the GCP service account"
  value       = google_service_account.castai_cloud_connect.id
}

output "integration_id" {
  description = "ID of the Cast AI cloud asset integration"
  value       = restapi_object.castai_integration.id
}

output "is_org_scoped" {
  description = "Whether this is an organization-scoped integration"
  value       = local.is_org_scoped
}

output "custom_role_ids" {
  description = "IDs of the custom IAM roles (empty if not created)"
  value = (
    local.has_custom_role && local.is_org_scoped ? [for r in google_organization_iam_custom_role.castai_cloud_connect : r.id] :
    local.has_custom_role && !local.is_org_scoped ? [google_project_iam_custom_role.castai_cloud_connect[0].id] :
    []
  )
}
