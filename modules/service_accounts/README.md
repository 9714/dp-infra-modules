# service_accounts

dbt / Cloud Run Jobs / Workflows の 3 サービスアカウントを作成し、それぞれの email を output するモジュール。

IAM 付与はモジュールに含まない。権限付与は GCS バケット名・AR リポジトリ名などの案件固有リソースに依存するため、呼び出し側（`{client}-infra`）で `google_project_iam_member` を定義すること。

## Usage

```hcl
module "service_accounts" {
  source = "git::https://github.com/your-org/dp-infra-modules.git//modules/service_accounts?ref=v1.0.0"

  project_id  = "acmecorp-dev"
  client_name = "acmecorp"
  env         = "dev"
}

# IAM 付与は呼び出し側で定義する例
resource "google_project_iam_member" "dbt_bq_editor" {
  project = "acmecorp-dev"
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${module.service_accounts.dbt_sa_email}"
}
```

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.7   |
| google    | ~> 6.0   |

## Inputs

| Name          | Description                                          | Type     | Required |
|---------------|------------------------------------------------------|----------|----------|
| `project_id`  | GCP project ID where service accounts are created    | `string` | yes      |
| `client_name` | Client identifier used as a prefix for SA IDs        | `string` | yes      |
| `env`         | Deployment environment (`dev`, `stg`, or `prd`)      | `string` | yes      |

## Outputs

| Name                 | Description                                   |
|----------------------|-----------------------------------------------|
| `dbt_sa_email`       | Email of the dbt service account              |
| `cloud_run_sa_email` | Email of the Cloud Run Jobs service account   |
| `workflows_sa_email` | Email of the Workflows service account        |

## Naming Convention

作成されるサービスアカウントの `account_id` は以下の規則に従う。

```
{client_name}-{env}-dbt
{client_name}-{env}-cloud-run
{client_name}-{env}-workflows
```
