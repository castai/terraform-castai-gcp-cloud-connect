variable "castai_api_url" {
  description = "Cast AI API URL"
  type        = string
  default     = "https://api.cast.ai"
}

variable "castai_api_key" {
  description = "Cast AI API key"
  type        = string
  sensitive   = true
}

variable "castai_organization_id" {
  description = "Cast AI organization ID"
  type        = string
}

variable "integration_name" {
  description = "Name for the cloud asset integration"
  type        = string
  default     = "GCP Cloud Connect"
}

variable "project_id" {
  description = "GCP project ID where the service account will be created. Defaults to the google provider's configured project."
  type        = string
  default     = null
}

variable "organization_ids" {
  description = "List of GCP organization IDs. When set, the module creates organization-level IAM bindings. When empty, organizations are auto-discovered; if none found, falls back to project-level bindings."
  type        = list(string)
  default     = []
}

variable "project_ids" {
  description = "List of GCP project IDs to enable APIs and bind roles in. When empty, all active projects visible to the caller are discovered automatically."
  type        = list(string)
  default     = []
}

variable "billing_account_ids" {
  description = "List of GCP billing account IDs for IAM bindings. Only used in org-scoped mode."
  type        = list(string)
  default     = []
}

variable "enable_project_apis" {
  description = "If true, the module will enable the necessary APIs for the projects. Defaults to false assuming that APIs are managed elsewhere not to create noise in the plan."
  type        = bool
  default     = false
}

variable "service_account_name" {
  description = "Name of the GCP service account to create"
  type        = string
  default     = "castai-cloud-connect"
}

variable "custom_role_id" {
  description = "ID for the custom IAM role. Only used for GCP_COMMITMENTS scope."
  type        = string
  default     = "castai_cloud_connect_role"
}

variable "scope" {
  description = "Integration scope: ALL, ALL_MINIMAL_PERMISSIONS, or GCP_COMMITMENTS"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "ALL_MINIMAL_PERMISSIONS", "GCP_COMMITMENTS"], var.scope)
    error_message = "Scope must be one of: ALL, ALL_MINIMAL_PERMISSIONS, GCP_COMMITMENTS"
  }
}

variable "commitments_default_status" {
  description = "Default autoscaling status for imported commitments. One of: ACTIVE (commitment will be used for autoscaling), INACTIVE (commitment will not be used for autoscaling)."
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.commitments_default_status)
    error_message = "commitments_default_status must be one of: ACTIVE, INACTIVE."
  }
}

variable "commitments_auto_assignment" {
  description = "Whether to automatically assign commitments to workloads."
  type        = bool
  default     = true
}

variable "integration_enabled" {
  description = "Whether the cloud asset integration is enabled. If set to false, the integration will remain configured but will not actively process data until re-enabled."
  type        = bool
  default     = true
}
