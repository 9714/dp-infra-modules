# dp-infra-modules

各案件のインフラ作成時の共通テンプレート・運用ガイド。

- **Terraform state 用 GCS バケット**: 手動作成
- **dbt artifacts 用 GCS バケット**: dbt リポジトリで管理

---

## モジュール一覧

案件リポジトリから Git URL + `?ref=タグ` で参照する。

| モジュール | 呼び出し元リポジトリ | 概要 |
|---|---|---|
| `artifact_registry` | `{client}-infra` | Artifact Registry リポジトリ（「箱」）を作成する。Cloud Run Jobs がイメージを push/pull するより前に存在する必要があるため infra で管理する |
| `service_accounts` | `{client}-infra` | dbt / Cloud Run Jobs / Workflows の 3 SA を作成し email を output する。IAM 付与は呼び出し側で定義する |
| `bigquery` | `{client}-dbt` | データセットを作成し、`dbt_sa_email` への権限付与まで担う。データセット定義は dbt リポジトリで一元管理する |
| `bigquery_iam` | `{client}-dbt` | BI ツール等の参照権限を管理する。モデル構成の変更と同じリポジトリ・同じ PR で完結させる |
| `cloud_run_job` | `{client}-pipeline` | Cloud Run Job を作成する。1 Job = 1 モジュール呼び出しで定義し、イメージ URL・SA・`task_count` はすべて変数で受け取る |
| `workflow` | `{client}-pipeline` | Cloud Workflows と Cloud Scheduler をセットで管理する。Scheduler → Workflows 起動権限の IAM もモジュールに含む |

### モジュールの参照方法

```hcl
module "service_accounts" {
  source = "git::https://github.com/your-org/dp-infra-modules.git//modules/service_accounts?ref=v1.0.0"

  project_id  = var.project_id
  client_name = var.client_name
  env         = var.env
}
```

---

## 各案件での利用方法

### 1. 案件用インフラリポジトリの構成

各案件ごとにインフラ用の Terraform リポジトリ（またはディレクトリ）を用意する。全環境の値を1ファイル `config.tfvars` にまとめて管理する。

```
your-project-infra/
├── main.tf
├── variables.tf
├── backend.tf
├── config.tfvars             # 全環境の変数を一元管理
└── modules/                  # 案件固有のモジュール（あれば）
```

### 2. 初回セットアップ（Terraform state バケットの手動作成）

Terraform state 用 GCS バケットは**手動で作成**する。backend 利用にはバケットが事前に必要なため。

命名規則: `{client_name}-tfstate-{env}`

```bash
# dev / stg / prd の 3 環境分作成する
gcloud storage buckets create gs://acmecorp-tfstate-dev \
  --project=your-project-dev \
  --location=asia-northeast1 \
  --uniform-bucket-level-access
```

### 3. config.tfvars の例

全環境を1ファイルにまとめて管理する。CI/CD 側で `env` を渡すことで対象環境を切り替える。

```hcl
# config.tfvars
environments = {
  dev = {
    project_id  = "acmecorp-dev"
    client_name = "acmecorp"
    location    = "asia-northeast1"
  }
  stg = {
    project_id  = "acmecorp-stg"
    client_name = "acmecorp"
    location    = "asia-northeast1"
  }
  prd = {
    project_id  = "acmecorp-prd"
    client_name = "acmecorp"
    location    = "asia-northeast1"
  }
}
```

`variables.tf` 側で `env` 変数を受け取り、`var.environments[var.env]` で参照する。

```hcl
# variables.tf
variable "env" {
  type = string
}

variable "environments" {
  type = map(object({
    project_id  = string
    client_name = string
    location    = string
  }))
}
```

```hcl
# main.tf
locals {
  config = var.environments[var.env]
}
```

### 4. Backend（remote state）の設定

`backend.tf` は bucket を空にしておき、`terraform init` 時に `-backend-config` でバケット名を指定する。バケット名は命名規則（`{client_name}-tfstate-{env}`）に従って組み立てる。

```hcl
# backend.tf
terraform {
  backend "gcs" {
    prefix = "infra"
  }
}
```

```bash
# dev の場合
terraform init -backend-config="bucket=acmecorp-tfstate-dev" -reconfigure
```

### 5. 利用手順

`-var-file` で `config.tfvars` を指定し、`-var "env=..."` で対象環境を切り替える。

```bash
cd your-project-infra

# dev
terraform init -backend-config="bucket=acmecorp-tfstate-dev" -reconfigure
terraform plan  -var-file=config.tfvars -var="env=dev"
terraform apply -var-file=config.tfvars -var="env=dev"

# stg
terraform init -backend-config="bucket=acmecorp-tfstate-stg" -reconfigure
terraform plan  -var-file=config.tfvars -var="env=stg"
terraform apply -var-file=config.tfvars -var="env=stg"
```

CI/CD では `ENV` をブランチ・タグから自動導出し、`-backend-config` と `-var "env=${ENV}"` を組み立てる。

### 6. ブランチ戦略と環境デプロイ

案件リポジトリ（`{client}-infra`, `{client}-dbt`, `{client}-pipeline`）は以下のブランチ戦略で運用する。

| トリガー | 対象環境 | 変数ファイル |
|---|---|---|
| `feature-*` ブランチを remote に push | dev | `config-dev.tfvars` |
| `feature-*` → `main` へのマージ | stg | `config-stg.tfvars` |
| タグ付け（例: `v1.2.3`） | prd | `config-prd.tfvars` |

dev / stg / prd は**別 GCP プロジェクト**で運用する。

CI/CD の実装は案件リポジトリ共通のテンプレートを参照すること。
