class SmsVerificationService
  CODE_EXPIRY_MINUTES = 10

  def self.generate_code
    SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
  end

  def self.send_code(phone_number, code)
    to = normalize_phone(phone_number)
    from = ENV['TWILIO_PHONE_NUMBER']
    Rails.logger.info("[Twilio] FROM=#{from} TO=#{to}")
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    client.messages.create(
      from: from,
      to: to,
      body: "【Smart Entry Lot】認証コード: #{code}\n有効期限は#{CODE_EXPIRY_MINUTES}分です。"
    )
  end

  def self.valid_code?(user, input_code)
    return false if user.sms_code.blank?
    return false if user.sms_code_sent_at < CODE_EXPIRY_MINUTES.minutes.ago
    # タイミング攻撃を防ぐため定数時間比較を使用
    ActiveSupport::SecurityUtils.secure_compare(user.sms_code, input_code.to_s.strip)
  end

  # 国内形式（090-XXXX-XXXX）を E.164 形式（+8190XXXXXXXX）に変換
  def self.normalize_phone(phone_number)
    digits = phone_number.to_s.gsub(/\D/, '')
    digits.start_with?('0') ? "+81#{digits[1..]}" : "+#{digits}"
  end
end
