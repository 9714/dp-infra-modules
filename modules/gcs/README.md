# gcs モジュール

Terraform state用およびdbt artifact用のGCSバケットを作成するモジュール。

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| google | >= 5.0 |

## 作成されるリソース

| バケット種別 | 命名規則 | 用途 |
|-------------|----------|------|
| Terraform state | `{client_name}-tfstate-{env}` | Terraform remote stateの保存先 |
| dbt artifacts | `{client_name}-dbt-artifacts-{env}` | dbtのコンパイル成果物・マニフェスト等の保存先 |

## 前提

dev / stg / prd は**別GCPプロジェクト**で運用する想定。各プロジェクトごとに tfstate バケット・dbt artifacts バケットが作成される。

## 使用方法

```hcl
module "gcs" {
  source = "git::https://github.com/your-org/dbt-infra-modules.git//modules/gcs?ref=v1.0.0"

  project_id  = var.project_id
  client_name = var.client_name
  env         = var.env
  location    = var.location
}
```

## 変数一覧

| 変数名 | 説明 | 型 | 必須 | デフォルト |
|--------|------|-----|------|------------|
| project_id | GCPプロジェクトID | string | ○ | - |
| client_name | 案件・クライアント名 | string | ○ | - |
| env | 環境（dev / stg / prd） | string | ○ | - |
| location | GCSロケーション | string | ○ | - |
| force_destroy | バケット削除時の中身強制削除 | bool | - | false |
| labels | 追加ラベル | map(string) | - | {} |

## 出力一覧

| 出力名 | 説明 |
|--------|------|
| tfstate_bucket_name | Terraform state用バケット名 |
| tfstate_bucket_self_link | Terraform state用バケットのself_link |
| dbt_artifacts_bucket_name | dbt artifact用バケット名 |
| dbt_artifacts_bucket_self_link | dbt artifact用バケットのself_link |

## remote state の設定例

```hcl
terraform {
  backend "gcs" {
    bucket = "your-client-tfstate-dev"  # env に応じて dev/stg/prd
    prefix = "infra"
  }
}
```

## 既存利用者向け state 移行（v1.x → v2.x）

リファクタでリソースアドレスが変更された場合、以下を実行してください。

```bash
terraform state mv 'module.gcs.google_storage_bucket.tfstate' 'module.gcs.google_storage_bucket.buckets["tfstate"]'
terraform state mv 'module.gcs.google_storage_bucket.dbt_artifacts' 'module.gcs.google_storage_bucket.buckets["dbt_artifacts"]'
```
