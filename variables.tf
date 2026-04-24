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
  default     = "GCP discovery"
}

variable "project_id" {
  description = "GCP project ID where the service account will be created. Defaults to the google provider's configured project."
  type        = string
  default     = null
}

variable "organization_id" {
  description = "GCP organization ID. When set, the module creates organization-level IAM bindings. When empty, falls back to project-level bindings."
  type        = string
  default     = ""
}

variable "project_ids" {
  description = "List of GCP project IDs to enable APIs and bind roles in. When empty in project-scoped mode, only the service account project is used."
  type        = list(string)
  default     = []
}

variable "billing_account_ids" {
  description = "List of GCP billing account IDs for IAM bindings. Only used when organization_id is set."
  type        = list(string)
  default     = []
}

variable "service_account_name" {
  description = "Name of the GCP service account to create"
  type        = string
  default     = "castai-discovery"
}

variable "custom_role_id" {
  description = "ID for the custom IAM role. Only used for GCP_COMMITMENTS scope."
  type        = string
  default     = "castai_discovery_role"
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
  description = "Default status for imported commitments. One of: ACTIVE, INACTIVE."
  type        = string
  default     = "INACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.commitments_default_status)
    error_message = "commitments_default_status must be one of: ACTIVE, INACTIVE."
  }
}

variable "commitments_auto_assignment" {
  description = "Whether to automatically assign commitments to workloads."
  type        = bool
  default     = false
}
