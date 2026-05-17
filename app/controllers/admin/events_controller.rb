class Admin::EventsController < ApplicationController
  before_action :require_admin_login
  before_action :set_event, only: %i[show edit update destroy draw_lottery]
  layout 'admin'

  def index
    @events = if current_admin.role_store?
                current_admin.events.includes(:entries).order(created_at: :desc)
              else
                Event.includes(:entries, :admin).order(created_at: :desc)
              end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.admin_id = current_admin.id
    if @event.save
      schedule_lottery_job(@event)
      redirect_to admin_events_path, notice: 'イベントを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    old_mode = @event.lottery_mode
    old_scheduled_at = @event.lottery_scheduled_at
    if @event.update(event_params)
      reschedule_lottery_job(@event, old_mode, old_scheduled_at)
      redirect_to admin_events_path, notice: "イベントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    cancel_lottery_job(@event)
    @event.destroy!
    redirect_to admin_events_path, notice: "イベントを削除しました", status: :see_other
  end

  def draw_lottery
    cancel_lottery_job(@event)
    @event.execute_lottery!
    redirect_to admin_event_path(@event), notice: "抽選を実行しました。当選者 #{@event.winner_count} 名が選出されました。", status: :see_other
  rescue RuntimeError => e
    redirect_to admin_event_path(@event), alert: e.message, status: :see_other
  end 

  private

  def set_event
    @event = if current_admin.role_store?
               current_admin.events.find(params[:id])
             else
               Event.find(params[:id])
             end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_events_path, alert: '権限がないか、イベントが存在しません'
  end

  def event_params
    params.require(:event).permit(:title, :description, :entry_start_at, :entry_end_at, :lottery_status, :winner_count, :image, :lottery_mode, :lottery_scheduled_at)
  end

  def schedule_lottery_job(event)
    return unless event.scheduled?

    job = AutoLotteryJob.set(wait_until: event.lottery_scheduled_at).perform_later(event.id)
    event.update_column(:scheduled_job_id, job.provider_job_id)
  end

  def reschedule_lottery_job(event, old_mode, old_scheduled_at)
    # モードまたはスケジュール時刻が変わった場合のみ再登録
    return if event.lottery_mode == old_mode && event.lottery_scheduled_at == old_scheduled_at

    cancel_lottery_job(event)
    schedule_lottery_job(event)
  end

  def cancel_lottery_job(event)
    return if event.scheduled_job_id.blank?

    begin
      Object.const_get('GoodJob::Job').find_by(id: event.scheduled_job_id)&.discard
    rescue => e
      Rails.logger.warn("[LotteryJob] スケジュール済みジョブのキャンセル失敗: #{e.message}")
    ensure
      event.update_column(:scheduled_job_id, nil)
    end
  end
end
