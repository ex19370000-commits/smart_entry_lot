GoodJob.configure do |config|
  # Pumaシングルモードでウェブプロセス内にジョブスレッドを起動
  config.execution_mode = :async_server
  # cronスケジューラを明示的に有効化
  config.enable_cron = true
  config.cron = {
    auto_lottery: {
      cron: '*/5 * * * *',
      class: 'AutoLotteryJob',
      description: '応募受付終了イベントの自動抽選'
    }
  }
end
