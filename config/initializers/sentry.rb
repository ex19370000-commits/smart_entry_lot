Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']

  # DSN未設定（開発環境・DSN未取得時）はSentryを完全に無効化する
  config.enabled_environments = %w[production]

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # パフォーマンストレースは無料枠を圧迫しないよう抑えめに設定
  config.traces_sample_rate = 0.1

  # 個人情報（電話番号・LINEプロフィール等）を誤送信しないようリクエストボディは送らない
  config.send_default_pii = false
end
