<a href="https://cast.ai">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/full-logo-white.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/full-logo-black.svg">
    <img src=".github/full-logo-black.svg" alt="Cast AI logo" title="Cast AI" align="right" height="50">
  </picture>
</a>

# Terraform module for GCP Cloud Connect onboarding

This Terraform module onboards GCP projects and organizations to [Cast AI Cloud Connect](https://cast.ai/) for cloud asset discovery. It is a declarative, auditable, and version-controlled alternative to the shell-based onboarding script.

## Deployment modes

### Organization-scoped

Binds IAM roles at the GCP organization level, granting Cast AI visibility across all projects in the organization. Also enables billing account bindings for commitment tracking.

Organizations are auto-discovered by default. Use `organization_ids` to limit bindings to specific organizations.

```hcl
module "castai_gcp_integration" {
  source = "castai/gcp-cloud-connect/castai"

  castai_api_key         = var.castai_api_key
  castai_organization_id = var.castai_organization_id

  project_id          = "my-gcp-project"
  organization_ids    = ["123456789"]  # optional, limits discovery to these orgs
  billing_account_ids = ["AAAAAA-BBBBBB-CCCCCC"]
}
```

### Project-scoped

Binds IAM roles directly to one or more GCP projects. This mode is used when `project_ids` is explicitly set, or when no organizations are visible to the caller.

Setting `project_ids` also skips organization discovery. `project_id` (the project where the service account is created) defaults to the google provider's configured project if not set.

```hcl
module "castai_gcp_integration" {
  source = "castai/gcp-cloud-connect/castai"

  castai_api_key         = var.castai_api_key
  castai_organization_id = var.castai_organization_id

  project_id  = "my-gcp-project"              # optional, defaults to provider's project
  project_ids = ["my-gcp-project", "another-project"]  # optional, limits discovery to these projects
}
```

> **Note:** Without organization-level access, flex CUDs and billing data will not be synced.

| Mode | When | IAM binding level | Billing access |
|------|------|-------------------|----------------|
| Org-scoped | Organizations discovered or `organization_ids` set | Organization | Yes (with `billing_account_ids`) |
| Project-scoped | `project_ids` explicitly set, or no organizations found | Project | No |

## Quick start

```hcl
module "castai_gcp_integration" {
  source = "castai/gcp-cloud-connect/castai"

  castai_api_key         = var.castai_api_key
  castai_organization_id = var.castai_organization_id

  project_id  = "my-gcp-project"
  project_ids = ["my-gcp-project"]
}
```

See [`examples/`](examples/) for more configurations.

## Scopes

| Scope | Permissions | Use case |
|-------|-------------|----------|
| `ALL` (default) | `roles/reader`, `roles/viewer` (+ billing roles at org level) | Full cloud asset discovery |
| `ALL_MINIMAL_PERMISSIONS` | Compute, GKE, Cloud SQL, AI Platform, Service Usage viewers | Minimal footprint discovery |
| `GCP_COMMITMENTS` | Billing viewer + custom role with commitment permissions | Commitment and CUD tracking |

## Commitments

To configure how imported commitments (CUDs) are handled:

```hcl
module "castai_gcp_integration" {
  source = "castai/gcp-cloud-connect/castai"

  castai_api_key         = var.castai_api_key
  castai_organization_id = var.castai_organization_id

  project_id      = "my-gcp-project"
  organization_id = "123456789"
  scope           = "GCP_COMMITMENTS"

  commitments_default_status  = "ACTIVE"
  commitments_auto_assignment = true
}
```

## Known issues

**"Provider produced inconsistent result after apply" on integration update**

When changing fields like `integration_name` or settings, `terraform apply` may report:

```
Error: Provider produced inconsistent result after apply
```

This is a false positive caused by a [bug in the restapi provider](https://github.com/Mastercard/terraform-provider-restapi/pull/359) where the `Update` function doesn't respect `ignore_all_server_changes`. The integration is actually updated correctly on the API side. Running `terraform plan` again will show no pending changes.

## Troubleshooting

**Cloud Connect synchronization fails for some projects**

By default, the module does not enable GCP APIs in discovered projects (`enable_project_apis = false`). This keeps the Terraform plan clean but means the required APIs (`compute.googleapis.com`, `serviceusage.googleapis.com`, etc.) must already be enabled in each project.

If Cloud Connect reports synchronization failures for certain projects, enable API management:

```hcl
module "castai_gcp_integration" {
  # ...
  enable_project_apis = true
}
```

This will enable the required APIs in all discovered projects. The first apply may show many resources being created (2 APIs per project, 4 for the service account project), but subsequent plans will be clean.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.29.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_restapi"></a> [restapi](#provider\_restapi) | 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_billing_account_iam_member.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_organization_iam_custom_role.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.castai_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_custom_role.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.castai_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.castai_cloud_connect](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [restapi_object.castai_integration](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |
| [google_organizations.all](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organizations) | data source |
| [google_project.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_projects.all](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [http_http.onboarding_config](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account_ids"></a> [billing\_account\_ids](#input\_billing\_account\_ids) | List of GCP billing account IDs for IAM bindings. Only used in org-scoped mode. | `list(string)` | `[]` | no |
| <a name="input_castai_api_key"></a> [castai\_api\_key](#input\_castai\_api\_key) | Cast AI API key | `string` | n/a | yes |
| <a name="input_castai_api_url"></a> [castai\_api\_url](#input\_castai\_api\_url) | Cast AI API URL | `string` | `"https://api.cast.ai"` | no |
| <a name="input_castai_organization_id"></a> [castai\_organization\_id](#input\_castai\_organization\_id) | Cast AI organization ID | `string` | n/a | yes |
| <a name="input_commitments_auto_assignment"></a> [commitments\_auto\_assignment](#input\_commitments\_auto\_assignment) | Whether to automatically assign commitments to workloads. | `bool` | `true` | no |
| <a name="input_commitments_default_status"></a> [commitments\_default\_status](#input\_commitments\_default\_status) | Default autoscaling status for imported commitments. One of: ACTIVE (commitment will be used for autoscaling), INACTIVE (commitment will not be used for autoscaling). | `string` | `"ACTIVE"` | no |
| <a name="input_custom_role_id"></a> [custom\_role\_id](#input\_custom\_role\_id) | ID for the custom IAM role. Only used for GCP\_COMMITMENTS scope. | `string` | `"castai_cloud_connect_role"` | no |
| <a name="input_enable_project_apis"></a> [enable\_project\_apis](#input\_enable\_project\_apis) | If true, the module will enable the necessary APIs for the projects. Defaults to false assuming that APIs are managed elsewhere not to create noise in the plan. | `bool` | `false` | no |
| <a name="input_integration_name"></a> [integration\_name](#input\_integration\_name) | Name for the cloud asset integration | `string` | `"GCP Cloud Connect"` | no |
| <a name="input_organization_ids"></a> [organization\_ids](#input\_organization\_ids) | List of GCP organization IDs. When set, the module creates organization-level IAM bindings. When empty, organizations are auto-discovered; if none found, falls back to project-level bindings. diff test | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID where the service account will be created. Defaults to the google provider's configured project. | `string` | `null` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | List of GCP project IDs to enable APIs and bind roles in. When empty, all active projects visible to the caller are discovered automatically. | `list(string)` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Integration scope: ALL, ALL\_MINIMAL\_PERMISSIONS, or GCP\_COMMITMENTS | `string` | `"ALL"` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of the GCP service account to create | `string` | `"castai-cloud-connect"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_ids"></a> [custom\_role\_ids](#output\_custom\_role\_ids) | IDs of the custom IAM roles (empty if not created) |
| <a name="output_integration_id"></a> [integration\_id](#output\_integration\_id) | ID of the Cast AI cloud asset integration |
| <a name="output_is_org_scoped"></a> [is\_org\_scoped](#output\_is\_org\_scoped) | Whether this is an organization-scoped integration |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the GCP service account created for Cast AI |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | Fully qualified ID of the GCP service account |
<!-- END_TF_DOCS -->
