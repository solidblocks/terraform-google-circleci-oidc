locals {
  gcp_project_id             = "my-project-id"
  circleci_organization_name = "my-circleci-organization"
  circleci_organization_id   = "xxx-xx-xx-xx-xxx"
}


module "circleci_oidc" {
  source          = "solidblocks/circleci-oidc/google"
  version         = "0.0.2"
  circleci_org_id = local.circleci_organization_id
}


# ==== CircleCi Context Setup ====
resource "circleci_context" "gcp_oidc" {
  name = "gcp-oidc"
}

resource "circleci_context_environment_variable" "GCP_SERVICE_ACCOUNT_EMAIL" {
  variable   = "GCP_SERVICE_ACCOUNT_EMAIL"
  value      = module.circleci_oidc.service_account_email
  context_id = circleci_context.gcp_oidc.id
}

resource "circleci_context_environment_variable" "GCP_PROJECT_ID" {
  variable   = "GCP_PROJECT_ID"
  value      = local.gcp_project_id
  context_id = circleci_context.gcp_oidc.id
}

resource "circleci_context_environment_variable" "GCP_PROJECT_NUMBER" {
  variable   = "GCP_PROJECT_NUMBER"
  value      = module.circleci_oidc.project_number
  context_id = circleci_context.gcp_oidc.id
}

resource "circleci_context_environment_variable" "GCP_WIP_ID" {
  variable   = "GCP_WIP_ID"
  value      = module.circleci_oidc.workload_identity_pool_id
  context_id = circleci_context.gcp_oidc.id
}
resource "circleci_context_environment_variable" "GCP_WIP_PROVIDER_ID" {
  variable   = "GCP_WIP_PROVIDER_ID"
  value      = module.circleci_oidc.workload_identity_pool_provider_id
  context_id = circleci_context.gcp_oidc.id
}

