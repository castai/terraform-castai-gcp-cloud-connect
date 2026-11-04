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

output "static_key_retirement" {
  description = "Manual step for integrations previously registered with a static service account key (module versions before SA impersonation)"
  value       = <<-EOT
    Integrations first onboarded by an older module version authenticate with
    a static service account key. On upgrade this module switches the
    integration to SA impersonation in place, but it deliberately does NOT
    delete the old key: the credential switch happens via an API update and
    Terraform cannot order a key deletion after it, so a failed apply must
    never leave the integration without working credentials.

    Once the integration is verified to sync via impersonation, retire the
    old key manually. List the user-managed keys of
    ${google_service_account.castai_cloud_connect.email}:

      gcloud iam service-accounts keys list \
        --iam-account="${google_service_account.castai_cloud_connect.email}" \
        --project="${local.sa_project}" \
        --filter="keyType:USER_MANAGED" --format="value(name)"

    then delete each one:

      gcloud iam service-accounts keys delete <KEY_ID> \
        --iam-account="${google_service_account.castai_cloud_connect.email}" \
        --project="${local.sa_project}"
  EOT
}
