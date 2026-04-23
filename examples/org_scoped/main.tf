provider "google" {
  project = var.gcp_project_id
}

module "castai_gcp_integration" {
  source = "../../"

  castai_api_key         = var.castai_api_key
  castai_organization_id = var.castai_organization_id

  project_id          = var.gcp_project_id
  organization_id     = var.gcp_organization_id
  billing_account_ids = var.gcp_billing_account_ids
  scope               = "ALL"

  integration_name = "GCP Org Discovery via Terraform"
}

variable "castai_api_key" {
  type      = string
  sensitive = true
}

variable "castai_organization_id" {
  type = string
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_organization_id" {
  type = string
}

variable "gcp_billing_account_ids" {
  type    = list(string)
  default = []
}

output "service_account_email" {
  value = module.castai_gcp_integration.service_account_email
}

output "integration_id" {
  value = module.castai_gcp_integration.integration_id
}

output "is_org_scoped" {
  value = module.castai_gcp_integration.is_org_scoped
}
