resource "google_storage_bucket" "buckets" {
  for_each = local.buckets

  name     = each.value.name
  location = var.location
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = local.common_labels
}
