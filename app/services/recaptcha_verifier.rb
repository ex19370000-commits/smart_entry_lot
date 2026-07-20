class RecaptchaVerifier
  VERIFY_URL = 'https://www.google.com/recaptcha/api/siteverify'
  # v3スコアの閾値：0.5未満はボットと判定
  SCORE_THRESHOLD = 0.5

  Result = Struct.new(:success, :score, :action, :error_codes, keyword_init: true) do
    def human?
      success && score >= SCORE_THRESHOLD
    end
  end

  def self.verify(token:, remote_ip:)
    # テスト環境ではGoogleへのリクエストをスキップ
    return Result.new(success: true, score: 1.0, action: 'test', error_codes: []) if Rails.env.test?
    return Result.new(success: false, score: 0.0, action: nil, error_codes: ['missing-input-response']) if token.blank?

    response = Net::HTTP.post_form(
      URI(VERIFY_URL),
      secret:   ENV['RECAPTCHA_SECRET_KEY'],
      response: token,
      remoteip: remote_ip
    )
    parsed = JSON.parse(response.body)

    Result.new(
      success:     parsed['success'] == true,
      score:       parsed['score'].to_f,
      action:      parsed['action'],
      error_codes: parsed['error-codes'] || []
    )
  rescue StandardError => e
    Rails.logger.error("[reCAPTCHA] 検証リクエスト失敗: #{e.message}")
    # ネットワーク障害時は通過させる（ユーザー体験優先）
    Result.new(success: true, score: 1.0, action: nil, error_codes: [])
  end
end
