class LineMessagingService
  def initialize
    @client = Line::Bot::Client.new do |config|
      config.channel_secret      = ENV['LINE_MESSAGING_CHANNEL_SECRET']
      config.channel_token       = ENV['LINE_MESSAGING_CHANNEL_TOKEN']
    end
  end

  # 単一ユーザーへのプッシュ通知
  def push(line_uid, message_text)
    message = { type: 'text', text: message_text }
    response = @client.push_message(line_uid, message)
    response.code == '200'
  end

  # 複数ユーザーへの一括プッシュ（最大500件）
  def multicast(line_uids, message_text)
    return false if line_uids.empty?

    message = { type: 'text', text: message_text }
    response = @client.multicast_message(line_uids, message)
    response.code == '200'
  end
end
