# dp-infra-modules

各案件のインフラ作成時の共通テンプレート・運用ガイド。

- **Terraform state 用 GCS バケット**: 手動作成
- **dbt artifacts 用 GCS バケット**: dbt リポジトリで管理

---

## 各案件での利用方法

### 1. 案件用インフラリポジトリの構成

各案件ごとにインフラ用の Terraform リポジトリ（またはディレクトリ）を用意する。環境ごとの値は `config-{env}.tfvars` で切り替える。

```
your-project-infra/           # 案件ごとのインフラリポジトリ
├── main.tf
├── backend.tf
├── config-dev.tfvars         # dev 用変数
├── config-stg.tfvars         # stg 用変数
├── config-prd.tfvars         # prd 用変数
└── modules/                  # 案件固有のモジュール（あれば）
```

### 2. 初回セットアップ（Terraform state バケットの手動作成）

Terraform state 用 GCS バケットは**手動で作成**する。backend 利用にはバケットが事前に必要なため。

```bash
# 命名規則: {client_name}-tfstate-{env}
gcloud storage buckets create gs://acmecorp-tfstate-dev \
  --project=your-project-dev \
  --location=asia-northeast1 \
  --uniform-bucket-level-access
```

### 3. config.tfvars の例

環境ごとに `config-{env}.tfvars` を用意する。

```hcl
# config-dev.tfvars
project_id  = "your-project-dev"
client_name = "acmecorp"
env         = "dev"
location    = "asia-northeast1"
```

### 4. Backend（remote state）の設定

bucket は環境ごとに異なるため、`terraform init` 時に `-backend-config` で指定する。

```hcl
# backend.tf（部分設定。bucket は init 時に -backend-config で指定）
terraform {
  backend "gcs" {
    prefix = "infra"
  }
}
```

```bash
terraform init -backend-config="bucket=acmecorp-tfstate-dev" -reconfigure
```

または、backend 用の設定ファイルを用意する。

```hcl
# backend-dev.tfbackend
bucket = "acmecorp-tfstate-dev"
prefix = "infra"
```

```bash
terraform init -backend-config=backend-dev.tfbackend -reconfigure
```

### 5. 利用手順

```bash
cd your-project-infra
terraform init -backend-config="bucket=acmecorp-tfstate-dev" -reconfigure
terraform plan -var-file=config-dev.tfvars
terraform apply -var-file=config-dev.tfvars
```

環境を切り替える場合は、`-backend-config` と `-var-file` を揃える（例: stg なら `config-stg.tfvars` と `bucket=acmecorp-tfstate-stg`）。

### 6. 環境ごとの運用

| 環境 | 想定 |
|------|------|
| dev | 開発用 GCP プロジェクト。tfstate バケットを手動作成後、インフラを適用 |
| stg | ステージング用プロジェクト。`config-stg.tfvars` で適用 |
| prd | 本番用プロジェクト。`config-prd.tfvars` で適用 |

dev / stg / prd は**別 GCP プロジェクト**で運用する想定。
