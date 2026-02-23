locals {
  common_labels = merge(
    {
      env        = var.env
      managed_by = "terraform"
      module     = "dbt-infra-modules"
    },
    var.labels
  )

  buckets = {
    tfstate = {
      name = "${var.client_name}-tfstate-${var.env}"
    }
    dbt_artifacts = {
      name = "${var.client_name}-dbt-artifacts-${var.env}"
    }
  }
}
