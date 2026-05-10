class EventsController < ApplicationController
  # 一般ユーザー向けなので、今後必要に応じて layout を切り替えます
  
  def show
    # param: :public_token でルーティングを設定したため、params[:public_token] で検索します
    @event = Event.find_by!(public_token: params[:public_token])
    
    # 下書き状態の場合はアクセスさせない
    if @event.draft?
      redirect_to root_path, alert: "このイベントは現在非公開です。"
    end
  end
end