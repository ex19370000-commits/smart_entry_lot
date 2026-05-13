require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module SmartEntryLot
  class Application < Rails::Application
    config.load_defaults 7.0

    # --- ここから追記 ---
    # タイムゾーンを日本時間に設定
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # デフォルトの言語を日本語に変更
    config.i18n.default_locale = :ja
    # --- ここまで追記 ---

    # config.eager_load_paths << Rails.root.join("extras")

    config.active_job.queue_adapter = :good_job
    # cronスケジューラを有効化（デフォルト無効のため明示が必要）
    config.good_job.execution_mode = :async_server
    config.good_job.enable_cron   = true
    config.good_job.cron = {
      auto_lottery: {
        cron: '* * * * *',
        class: 'AutoLotteryJob',
        description: '応募受付終了イベントの自動抽選'
      }
    }
  end
end
