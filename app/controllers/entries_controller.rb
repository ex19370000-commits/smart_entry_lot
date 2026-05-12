class EntriesController < ApplicationController
  before_action :require_login
  before_action :require_sms_verified
  before_action :set_event

  def create
    entry = current_user.entries.build(event: @event)

    if entry.save
      redirect_to event_path(@event.public_token), notice: "応募が完了しました！抽選結果をお待ちください。"
    else
      redirect_to event_path(@event.public_token), alert: entry.errors.full_messages.first
    end
  end

  private

  def require_sms_verified
    unless current_user.phone_verified?
      redirect_to new_sms_verification_path(event_token: params[:event_token]), alert: "SMS認証が必要です"
    end
  end

  def set_event
    @event = Event.find_by!(public_token: params[:event_token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "イベントが見つかりません"
  end
end
