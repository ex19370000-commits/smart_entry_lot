class EntriesController < ApplicationController
  before_action :require_login
  before_action :require_sms_verified
  before_action :set_event

  def create
    # reCAPTCHA v3 スコア検証
    recaptcha_result = RecaptchaVerifier.verify(
      token:     params[:recaptcha_token],
      remote_ip: request.remote_ip
    )
    unless recaptcha_result.human?
      Rails.logger.warn("[reCAPTCHA] ボット疑い user_id=#{current_user.id} score=#{recaptcha_result.score} ip=#{request.remote_ip}")
      redirect_to event_path(@event.public_token), status: :see_other, alert: "お使いの環境では応募できません。LINEアプリから再度お試しください。"
      return
    end

    # cookieが異なる別ブラウザ・別端末からの応募を検知してブロック
    if cookie_duplicate?
      redirect_to event_path(@event.public_token), status: :see_other, alert: "このブラウザからは既に応募済みです"
      return
    end

    entry = current_user.entries.build(
      event: @event,
      cookie_uuid: cookies[:cookie_uuid],
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    if entry.save
      redirect_to event_path(@event.public_token), status: :see_other, notice: "応募が完了しました！抽選結果をお待ちください。"
    else
      redirect_to event_path(@event.public_token), status: :see_other, alert: entry.errors.full_messages.first
    end
  end

  private

  def require_sms_verified
    unless current_user.phone_verified?
      redirect_to new_sms_verification_path(event_token: params[:event_token]), status: :see_other, alert: "SMS認証が必要です"
    end
  end

  def set_event
    @event = Event.find_by!(public_token: params[:event_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, status: :see_other, alert: "イベントが見つかりません"
  end

  def cookie_duplicate?
    uuid = cookies[:cookie_uuid]
    uuid.present? && @event.entries.exists?(cookie_uuid: uuid)
  end
end
