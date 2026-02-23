mock_provider "google" {}

variables {
  project_id  = "acmecorp-dev"
  client_name = "acmecorp"
  env         = "dev"
}

# 正常系: 有効な変数でプランが通ること
run "test_valid_variables_accepted" {
  command = plan
}

# env バリデーション: 許可値以外は拒否されること
run "test_invalid_env_rejected" {
  command = plan

  variables {
    env = "production"
  }

  expect_failures = [
    var.env,
  ]
}

# client_name バリデーション: 不正な形式は拒否されること
run "test_invalid_client_name_rejected" {
  command = plan

  variables {
    client_name = "Invalid_Name!"
  }

  expect_failures = [
    var.client_name,
  ]
}
