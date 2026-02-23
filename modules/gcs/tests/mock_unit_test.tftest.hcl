# tests/mock_unit_test.tftest.hcl
#
# テスト対象はモジュールが呼び出し側に保証する「契約」のみ：
#   1. バケット命名規則
#   2. セキュリティ設定のハードコード値
#   3. force_destroy のデフォルト値
#   4. カスタムラベルと共通ラベルのマージ
#   5. env バリデーション（不正値の拒否）
#   6. 出力値がバケット名と一致すること

mock_provider "google" {
  mock_resource "google_storage_bucket" {
    defaults = {
      id                          = "mock-bucket-id"
      self_link                   = "https://www.googleapis.com/storage/v1/b/mock-bucket"
      url                         = "gs://mock-bucket"
      uniform_bucket_level_access = true
      public_access_prevention    = "enforced"
      force_destroy               = false
      labels                      = {}
      versioning = [{
        enabled = true
      }]
    }
  }
}

variables {
  project_id  = "mock-project"
  client_name = "acmecorp"
  env         = "dev"
  location    = "asia-northeast1"
}

# ------------------------------------------------------------
# 1. バケット命名規則
# ------------------------------------------------------------

run "bucket_names_follow_naming_convention" {
  command = plan

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].name == "acmecorp-tfstate-dev"
    error_message = "tfstate バケット名は {client_name}-tfstate-{env} である必要があります"
  }

  assert {
    condition     = google_storage_bucket.buckets["dbt_artifacts"].name == "acmecorp-dbt-artifacts-dev"
    error_message = "dbt_artifacts バケット名は {client_name}-dbt-artifacts-{env} である必要があります"
  }
}

# ------------------------------------------------------------
# 2. セキュリティ設定はハードコードで変更不可であること
# ------------------------------------------------------------

run "security_settings_are_hardcoded" {
  command = plan

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].uniform_bucket_level_access == true
    error_message = "uniform_bucket_level_access は常に true でなければなりません"
  }

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].public_access_prevention == "enforced"
    error_message = "public_access_prevention は常に enforced でなければなりません"
  }

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].versioning[0].enabled == true
    error_message = "versioning は常に有効でなければなりません"
  }
}

# ------------------------------------------------------------
# 3. force_destroy のデフォルトは false（本番安全のため）
# ------------------------------------------------------------

run "force_destroy_defaults_to_false" {
  command = plan

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].force_destroy == false
    error_message = "force_destroy のデフォルトは false である必要があります"
  }
}

# ------------------------------------------------------------
# 4. カスタムラベルは共通ラベルとマージされること
# ------------------------------------------------------------

run "custom_labels_merge_with_common_labels" {
  command = plan

  variables {
    labels = {
      team = "data-platform"
    }
  }

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].labels["team"] == "data-platform"
    error_message = "カスタムラベルがバケットに付与されている必要があります"
  }

  assert {
    condition     = google_storage_bucket.buckets["tfstate"].labels["managed_by"] == "terraform"
    error_message = "カスタムラベル追加後も共通ラベルが残っている必要があります"
  }
}

# ------------------------------------------------------------
# 5. env バリデーション（不正値は拒否される）
# ------------------------------------------------------------

run "invalid_env_is_rejected" {
  command = plan

  variables {
    env = "production"
  }

  expect_failures = [
    var.env
  ]
}

# ------------------------------------------------------------
# 6. 出力値がバケット名と一致すること
# ------------------------------------------------------------

run "outputs_match_bucket_names" {
  command = plan

  assert {
    condition     = output.tfstate_bucket_name == "acmecorp-tfstate-dev"
    error_message = "tfstate_bucket_name 出力がバケット名と一致しません"
  }

  assert {
    condition     = output.dbt_artifacts_bucket_name == "acmecorp-dbt-artifacts-dev"
    error_message = "dbt_artifacts_bucket_name 出力がバケット名と一致しません"
  }
}
