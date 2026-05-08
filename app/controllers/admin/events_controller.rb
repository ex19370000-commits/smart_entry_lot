class Admin::EventsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  layout 'admin'

  def index
    @events = Event.all.order(created_at: :desc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path, notice: 'イベントを作成しました'
    else
      # エラーがある場合は入力を保持したままnew画面を再表示
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :start_at, :end_at, :status, :image)
  end
end
