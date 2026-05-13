class AutoLotteryJob < ApplicationJob
  queue_as :default

  def perform
    Event.where(lottery_status: :published)
         .where('entry_end_at <= ?', Time.current)
         .where(lottery_executed_at: nil)
         .find_each do |event|
      begin
        event.update!(lottery_status: :closed)
        event.execute_lottery! if event.entries.any?
        Rails.logger.info("[AutoLottery] Event #{event.id} 抽選完了")
      rescue => e
        Rails.logger.error("[AutoLottery] Event #{event.id} 失敗: #{e.message}")
      end
    end
  end
end
