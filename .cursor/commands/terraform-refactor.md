# Terraform リファクタ

## 前提

**必ず最初に** `.cursor/.agents/skills/refactor-module/SKILL.md` を読み、その手順に従うこと。

## 目的

 monolithic な Terraform 設定を HashiCorp のモジュール設計指針に従い、再利用可能で保守しやすいモジュールへ変換する。

## 実行手順

1. **分析**
   - リソースを論理的な役割ごとにグルーピング
   - 重複パターンの特定
   - リソース依存関係の把握
   - 変数使用パターンの分析

2. **モジュール設計**
   - variables / outputs による明確なインターフェース
   - カプセル化の範囲決定（何をモジュールに含めるか）
   - バージョン・README の整備

3. **コード変換**
   - モジュール用ディレクトリ構造の作成
   - リソースの移行と変数化
   - 呼び出し側（root モジュール）の更新

4. **検証**
   - `terraform fmt` の実施
   - `terraform validate` の実行
   - 既存 state がある場合は移行計画の作成

## チェックリスト

- [ ] refactor-module skill を読み、手順を確認した
- [ ] 変数・出力のインターフェースを定義した
- [ ] リソース依存関係を保持している
- [ ] `terraform validate` が通る
- [ ] 必要に応じて README と変数の description を追記した
