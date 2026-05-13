Rails.application.configure do
  # Puma のウェブプロセス内でジョブを非同期実行（Redis・別プロセス不要）
  config.good_job.execution_mode = :async

  # 5分ごとに自動抽選ジョブを実行
  config.good_job.cron = {
    auto_lottery: {
      cron: '*/5 * * * *',
      class: 'AutoLotteryJob',
      description: '応募受付終了イベントの自動抽選'
    }
  }
end
