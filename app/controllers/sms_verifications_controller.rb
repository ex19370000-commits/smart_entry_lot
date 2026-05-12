class SmsVerificationsController < ApplicationController
  before_action :require_line_user

  def new
    @event_token = params[:event_token]
  end

  def create
    phone_number = params[:phone_number]
    @event_token = params[:event_token]

    if phone_number.blank?
      flash.now[:alert] = '電話番号を入力してください'
      return render :new
    end

    code = SmsVerificationService.generate_code

    begin
      SmsVerificationService.send_code(phone_number, code)
      current_user.update!(phone_number: phone_number)
      # 既存レコードがあれば上書き、なければ新規作成
      current_user.sms_verification&.destroy
      current_user.create_sms_verification!(code: code, sent_at: Time.current)
      redirect_to verify_sms_verifications_path(event_token: @event_token), status: :see_other
    rescue Twilio::REST::RestError => e
      Rails.logger.error("[Twilio Error] #{e.message}")
      flash.now[:alert] = 'SMS送信に失敗しました。電話番号をご確認ください。'
      render :new
    end
  end

  def verify
    @event_token = params[:event_token]
  end

  def confirm
    @event_token = params[:event_token]

    unless SmsVerificationService.valid_code?(current_user, params[:code])
      flash.now[:alert] = '認証コードが正しくないか、有効期限が切れています'
      return render :verify
    end

    # 検証完了後はレコードを削除してphone_verifiedをONにする
    current_user.sms_verification&.destroy
    current_user.update!(phone_verified: true)

    if @event_token.present?
      redirect_to event_path(@event_token), status: :see_other, notice: 'SMS認証が完了しました'
    else
      redirect_to root_path, status: :see_other, notice: 'SMS認証が完了しました'
    end
  end

  private

  def require_line_user
    return if current_user&.line_uid.present?

    redirect_to root_path, status: :see_other, alert: 'LINEログインが必要です'
  end
end
