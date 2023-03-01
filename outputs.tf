output "service_account_name" {
  value = var.existing_service_account_name == "" ? google_service_account.circleci[0].name : var.existing_service_account_name
}

output "service_account_email" {
  value = var.existing_service_account_name == "" ? google_service_account.circleci[0].email : data.google_service_account.existing_service_account[0].email
}

output "project_number" {
  value = data.google_project.project.number
}

output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.circleci.workload_identity_pool_id
}

output "workload_identity_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.circleci.workload_identity_pool_provider_id
}
