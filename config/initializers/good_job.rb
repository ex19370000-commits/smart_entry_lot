GoodJob.configuration.execution_mode = :async_server
GoodJob.configuration.enable_cron = true
GoodJob.configuration.cron = {
  auto_lottery: {
    cron: '*/5 * * * *',
    class: 'AutoLotteryJob',
    description: '応募受付終了イベントの自動抽選'
  }
}
