class EventsController < ApplicationController
  # 一般ユーザー向けなので、今後必要に応じて layout を切り替えます
  
  def show
    @event = Event.find_by!(public_token: params[:public_token])

    if @event.draft?
      redirect_to root_path, alert: "このイベントは現在非公開です。"
    else
      PageView.create!(event: @event, cookie_uuid: cookies[:cookie_uuid])
    end
  end
end