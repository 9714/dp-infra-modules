locals {
  prefix = "${var.client_name}-${var.env}"
}

resource "google_service_account" "dbt" {
  project      = var.project_id
  account_id   = "${local.prefix}-dbt"
  display_name = "${local.prefix} dbt Service Account"
}

resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "${local.prefix}-cloud-run"
  display_name = "${local.prefix} Cloud Run Jobs Service Account"
}

resource "google_service_account" "workflows" {
  project      = var.project_id
  account_id   = "${local.prefix}-workflows"
  display_name = "${local.prefix} Workflows Service Account"
}
