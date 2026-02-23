variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "client_name" {
  description = "案件・クライアント名（バケット名のプレフィックスに使用）"
  type        = string
}

variable "env" {
  description = "環境識別子（dev / stg / prd）"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.env)
    error_message = "env は dev, stg, prd のいずれかを指定してください。"
  }
}

variable "location" {
  description = "GCSバケットのロケーション（例: asia-northeast1, US）"
  type        = string
}

variable "force_destroy" {
  description = "バケット削除時に中身を強制削除するか（本番では false 推奨）"
  type        = bool
  default     = false
}

variable "labels" {
  description = "全バケットに付与する追加ラベル"
  type        = map(string)
  default     = {}
}
