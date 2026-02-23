output "dbt_sa_email" {
  description = "Email of the dbt service account"
  value       = google_service_account.dbt.email
}

output "cloud_run_sa_email" {
  description = "Email of the Cloud Run Jobs service account"
  value       = google_service_account.cloud_run.email
}

output "workflows_sa_email" {
  description = "Email of the Workflows service account"
  value       = google_service_account.workflows.email
}
