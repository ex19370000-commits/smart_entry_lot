class LotteryNotificationJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 500

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event&.already_drawn?

    winner_uids = event.entries.win.joins(:user).where.not(users: { line_uid: nil }).pluck('users.line_uid')
    loser_uids  = event.entries.lose.joins(:user).where.not(users: { line_uid: nil }).pluck('users.line_uid')

    service = LineMessagingService.new

    send_in_batches(service, winner_uids, win_message(event))
    send_in_batches(service, loser_uids,  lose_message(event))

    Rails.logger.info("[LotteryNotification] Event #{event.id} 通知完了 " \
                      "当選:#{winner_uids.size}件 落選:#{loser_uids.size}件")
  rescue => e
    Rails.logger.error("[LotteryNotification] Event #{event_id} 通知失敗: #{e.message}")
  end

  private

  def send_in_batches(service, uids, message)
    uids.each_slice(BATCH_SIZE) do |batch|
      success = service.multicast(batch, message)
      unless success
        Rails.logger.warn("[LotteryNotification] multicast 失敗 #{batch.size}件")
      end
    end
  end

  def win_message(event)
    <<~MSG.strip
      🎉 当選おめでとうございます！

      「#{event.title}」の抽選結果が出ました。
      あなたは見事【当選】されました！

      詳細・手続きはこちらからご確認ください。
      #{event.public_url}
    MSG
  end

  def lose_message(event)
    <<~MSG.strip
      「#{event.title}」の抽選結果をお知らせします。

      今回は残念ながら【落選】となりました。
      またの機会にぜひご応募ください。

      #{event.public_url}
    MSG
  end
end
