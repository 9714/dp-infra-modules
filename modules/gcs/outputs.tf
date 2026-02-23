output "dbt_artifacts_bucket_id" {
  description = "dbt artifact用GCSバケットのID"
  value       = google_storage_bucket.buckets["dbt_artifacts"].id
}

output "dbt_artifacts_bucket_name" {
  description = "dbt artifact用GCSバケット名"
  value       = google_storage_bucket.buckets["dbt_artifacts"].name
}

output "dbt_artifacts_bucket_self_link" {
  description = "dbt artifact用GCSバケットのself_link"
  value       = google_storage_bucket.buckets["dbt_artifacts"].self_link
}

output "tfstate_bucket_id" {
  description = "Terraform state用GCSバケットのID"
  value       = google_storage_bucket.buckets["tfstate"].id
}

output "tfstate_bucket_name" {
  description = "Terraform state用GCSバケット名"
  value       = google_storage_bucket.buckets["tfstate"].name
}

output "tfstate_bucket_self_link" {
  description = "Terraform state用GCSバケットのself_link"
  value       = google_storage_bucket.buckets["tfstate"].self_link
}
