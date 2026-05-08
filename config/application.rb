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
  end
end
