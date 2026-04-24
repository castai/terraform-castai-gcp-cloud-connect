output "service_account_email" {
  description = "Email of the GCP service account created for Cast AI"
  value       = google_service_account.castai_discovery.email
}

output "service_account_id" {
  description = "Fully qualified ID of the GCP service account"
  value       = google_service_account.castai_discovery.id
}

output "integration_id" {
  description = "ID of the Cast AI cloud asset integration"
  value       = restapi_object.castai_integration.id
}

output "is_org_scoped" {
  description = "Whether this is an organization-scoped integration"
  value       = local.is_org_scoped
}

output "custom_role_id" {
  description = "ID of the custom IAM role (null if not created)"
  value = (
    local.has_custom_role && local.is_org_scoped ? google_organization_iam_custom_role.castai_discovery[0].id :
    local.has_custom_role && !local.is_org_scoped ? google_project_iam_custom_role.castai_discovery[0].id :
    null
  )
}
