class AutoLotteryJob < ApplicationJob
  queue_as :default

  def perform(event_id = nil)
    scope = if event_id
              Event.where(id: event_id)
            else
              # cronからの自動実行：autoモードのイベントのみ対象
              Event.where(lottery_status: :published)
                   .where(lottery_mode: :auto)
                   .where('entry_end_at <= ?', Time.current)
                   .where(lottery_executed_at: nil)
            end

    scope.find_each do |event|
      begin
        event.update!(lottery_status: :closed)
        event.execute_lottery! if event.entries.any?
        Rails.logger.info("[AutoLottery] Event #{event.id} 抽選完了")
      rescue => e
        Rails.logger.error("[AutoLottery] Event #{event.id} 失敗: #{e.message}")
        Sentry.capture_exception(e, extra: { event_id: event.id })
      end
    end
  end
end
