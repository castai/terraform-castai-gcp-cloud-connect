data "google_project" "default" {
  count = var.project_id == null ? 1 : 0
}

data "google_projects" "all" {
  count  = length(var.project_ids) == 0 ? 1 : 0
  filter = "lifecycleState:ACTIVE"
}

data "http" "onboarding_config" {
  url = "${var.castai_api_url}/inventory/v1beta/organizations/${var.castai_organization_id}/cloud-asset-integrations:getOnboardingConfig?provider=GCP&scope=${var.scope}"

  request_headers = {
    X-Api-Key = var.castai_api_key
  }
}

check "onboarding_config_status" {
  assert {
    condition     = data.http.onboarding_config.status_code == 200
    error_message = "Failed to fetch onboarding config from Cast AI API (status: ${data.http.onboarding_config.status_code}). Check castai_api_url and castai_api_key."
  }
}

check "has_projects" {
  assert {
    condition     = length(local.all_project_ids) > 0
    error_message = "No projects found. Either set project_ids explicitly or ensure the caller has permission to list projects."
  }
}

check "onboarding_config_has_roles" {
  assert {
    condition = (
      length(local.org_roles) > 0 ||
      length(local.project_roles) > 0 ||
      local.has_custom_role
    )
    error_message = "Onboarding config returned no roles or permissions for scope '${var.scope}'. The service account would have no access."
  }
}

locals {
  onboarding_config = jsondecode(data.http.onboarding_config.response_body)
}
