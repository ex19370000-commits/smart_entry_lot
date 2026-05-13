class Admin::EventsController < ApplicationController
  before_action :require_admin_login
  before_action :set_event, only: %i[show edit update destroy draw_lottery]
  layout 'admin'

  def index
    @events = Event.includes(:entries).order(created_at: :desc)
  end

  def show
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

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "イベントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to admin_events_path, notice: "イベントを削除しました", status: :see_other
  end

  def draw_lottery
    @event.execute_lottery!
    redirect_to admin_event_path(@event), notice: "抽選を実行しました。当選者 #{@event.winner_count} 名が選出されました。", status: :see_other
  rescue RuntimeError => e
    redirect_to admin_event_path(@event), alert: e.message, status: :see_other
  end 

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :entry_start_at, :entry_end_at, :lottery_status, :winner_count, :image)
  end
end
