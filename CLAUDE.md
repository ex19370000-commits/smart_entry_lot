# CLAUDE.md — Smart Entry Lot

## プロジェクト概要

**Smart Entry Lot（スマート・エントリー・ロット）**
LINEログイン・SMS認証・Cookie識別を組み合わせた「単体完結型」の抽選応募・管理プラットフォーム。
ボットや多重申込を排除し、本当に欲しい人が公平に当選できる仕組みを提供する。

---

## 言語・成果物ルール

- **コード**：英語（変数名・メソッド名・クラス名はすべて英語）
- **コメント**：日本語（コードの「なぜ」を日本語で書く。「何をしているか」は書かない）
- **ドキュメント・説明文**：日本語（README、設計メモ、コミットメッセージ等）
- **コミットメッセージ**：日本語で体言止め（例：「LINEログイン連携処理を実装」）

---

## 技術スタック

| カテゴリ | 技術 |
| :--- | :--- |
| 言語 | Ruby 3.1.4 |
| フレームワーク | Rails 7.0.10 |
| DB | PostgreSQL（スキーマは `db/schema.rb` が正）|
| 認証 | Sorcery |
| LINE連携 | line-bot-api（LIFF SDK） |
| SMS認証 | Twilio（Lookup APIでモバイル回線のみ許可） |
| 非同期処理 | Sidekiq + Redis |
| QRコード | rqrcode |
| スケジューラ | whenever |
| テスト | RSpec + FactoryBot + Capybara |
| 静的解析 | RuboCop |
| i18n | rails-i18n（日本語化） |
| ファイルストレージ | Active Storage + AWS S3 |
| デプロイ | Render.com（`render.yaml` で定義） |
| 開発環境 | Docker（`docker-compose.yml`） |

> **注意**：README には MySQL と記載があるが、実際は PostgreSQL に変更済み。

---

## アーキテクチャ

### ルーティング構成

```
/                         → top#index（トップページ）
/admin/...                → 管理者専用（namespace :admin）
  /admin/login            → admin/user_sessions（Sorcery）
  /admin/events           → admin/events（イベントCRUD）
/events/:public_token     → events#show（応募者向け公開ページ）
/line_users               → line_users#create（LIFF からの登録API）
```

### 主要モデル

| モデル | 役割 |
| :--- | :--- |
| `User` | 応募者・管理者。LINEログイン時は `line_user_id` で識別 |
| `Event` | 抽選イベント。`public_token` でURLを一意に生成 |
| `Shop` | 店舗情報 |
| `Entry` | 応募エントリー（`user_id` + `shop_id`） |

### 重要な設計上の決定事項

- **`Event#public_token`**：`has_secure_token` でランダム生成。URLに `/events/:public_token` を使い、IDを隠蔽する。
- **LINEユーザーの email 問題**：Sorcery は `email` を NOT NULL で要求するため、LINE 登録時は `line_<line_user_id>@example.com` のダミーメールを裏側でセットする（`LineUsersController#create`）。
- **`Event#public_url`**：本番は `smart-entry-lot.onrender.com`、開発は ngrok の固定ドメインを使用。ngrok ドメインが変わった場合は `app/models/event.rb` の `public_url` メソッドを更新すること。

---

## 開発環境のセットアップ

```bash
docker-compose up
bin/rails db:migrate
bin/rails db:seed
```

LINE の LIFF 動作確認には ngrok が必要。

```bash
ngrok http --domain=skinless-caterer-gecko.ngrok-free.dev 3000
```

---

## 実装状況（2026-05-12 時点）

### 完了済み
- 管理者ログイン（Sorcery）
- イベントの作成・編集・削除（管理画面）
- `public_token` によるイベント公開URL・QRコード生成
- 応募者向けイベント詳細ページ（`/events/:public_token`）
- LIFF SDK の導入・LINEログイン連携（`LineUsersController`）
- `users` テーブルへの `line_user_id`・`picture_url` カラム追加

### 実装中（現在ブランチ：`feature/line-user-registration`）
- LINEユーザー登録フロー（`line_users#create`）の完成
- LINEログイン後のセッション確立

### 未実装（MVP残タスク）
- Cookie による同一ブラウザ検知ロジック
- SMS認証（Twilio）
- 応募エントリー機能（`Entry` モデルの `event_id` 紐付け含む）
- 抽選実行・結果表示

---

## コーディング規約

- **RuboCop** を使用。`rubocop -a` で自動修正してからコミットすること。
- `app/controllers/admin/` 以下はすべて管理者向け。`before_action :require_login` を必ず適用すること。
- `LineUsersController` は LIFF（ブラウザ）から JSON で叩かれるため `protect_from_forgery with: :null_session`。
- モデルのバリデーションは `app/models/` に書く。コントローラに書かない。
- `enum` を使う場合は `enum_help` で日本語ラベルを定義すること。

---

## テスト

```bash
bin/rspec                    # 全テスト実行
bin/rspec spec/models/       # モデルのみ
bin/rspec spec/requests/     # リクエストスペックのみ
```

- テストフレームワーク：RSpec
- フィクスチャ：FactoryBot（`spec/factories/`）
- E2E：Capybara + Selenium

---

## デプロイ

Render.com に `render.yaml` で定義済み。`main` ブランチへのマージで自動デプロイ。

```bash
# ローカルでマイグレーション確認
bin/rails db:migrate:status
```

本番DBのマイグレーションは Render のダッシュボードまたは `bin/render-build.sh` 経由で実行される。
