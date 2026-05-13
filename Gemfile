source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

# Rails 7.0系
gem "rails", "~> 7.0.10"

# Scss
gem 'sassc-rails'

# データベース: PostgreSQLに変更 [設計の決定事項を反映]
gem "pg"

# アセットパイプライン・フロントエンド
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Webサーバー
gem "puma", ">= 5.0"

# JSON生成
gem "jbuilder"

# タイムゾーンデータ
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# 起動高速化
gem "bootsnap", require: false

# 画像処理 (Active Storageでアイテム写真を扱うために必要)
gem "image_processing", "~> 1.2"

# --- 認証・認可 ---
gem "sorcery"
gem "bcrypt", "~> 3.1.7"

# --- AWS S3接続用 ---
gem "aws-sdk-s3", require: false

# --- 外部API連携・非同期処理 ---
gem "line-bot-api" # LINEログイン/通知用
gem "twilio-ruby"  # SMS認証用
gem "good_job"      # DB（PostgreSQL）ベースの非同期・定期実行

# --- MVP機能・ツール ---
gem "rqrcode"       # 応募用QRコード生成用

# --- その他便利なgem ---
gem 'rails-i18n' # 日本語化
gem 'enum_help' # enumの日本語化

group :development, :test do
  # デバッグ
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # テストフレームワーク
  gem "rspec-rails"
  gem "factory_bot_rails"
  # コンソール・デバッグツール
  gem "pry-rails"
  gem "pry-byebug"
  # 静的解析
  gem "rubocop", require: false
end

group :development do
  # エラー画面のコンソール
  gem "web-console"
end

group :test do
  # システムテスト
  gem "capybara"
  gem "selenium-webdriver"
end