# Terraform テスト

## 前提

**必ず最初に** `.cursor/.agents/skills/terraform-test/SKILL.md` を読み、その手順に従うこと。

**本リポジトリの方針**: モジュールのため **mock_unit_test のみ**（integration test は実施しない）。README および `.cursor/rules/terraform-test-policy.mdc` を参照。

## 目的

モジュールの「契約」（命名規則、設定値、バリデーション、出力）を mock provider + plan mode で検証する。

## 実行手順

1. **テスト設計**
   - モジュールの契約項目を整理
   - mock_provider でモック定義

2. **テストファイル作成**
   - `tests/mock_unit_test.tftest.hcl` に配置
   - `run` ブロックでシナリオ定義（command = plan）
   - `assert` ブロックで検証条件を記述

3. **テスト実行**
   - `terraform test` で実行
   - 失敗があれば修正し、再実行

## チェックリスト

- [ ] terraform-test skill を読み、手順を確認した
- [ ] mock_unit_test のみ（integration test は作らない）
- [ ] 各 run ブロックに適切な assert を追加した
- [ ] `terraform test` が成功する
