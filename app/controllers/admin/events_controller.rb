class Admin::EventsController < ApplicationController
  before_action :require_admin_login
  before_action :set_event, only: %i[show edit update destroy draw_lottery dashboard export_entries notification_status scanner verify_checkin]
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

  def dashboard
    entries  = @event.entries
    @period  = params[:period] || '7days'
    range, @labels, keys = build_chart_range(@period)

    page_views     = @event.page_views
    raw_access     = page_views.where(created_at: range).group(group_key(@period)).distinct.count(:cookie_uuid).transform_keys(&:to_s)
    raw_entries    = entries.where(created_at: range).group(group_key(@period)).count.transform_keys(&:to_s)
    @chart_access  = keys.map { |k| raw_access[k] || 0 }
    @chart_entries = keys.map { |k| raw_entries[k] || 0 }

    total_access     = page_views.distinct.count(:cookie_uuid)
    total_entries    = entries.count
    @entry_rate      = total_access > 0 ? (total_entries.to_f / total_access * 100).round(1) : 0

    line_users       = entries.joins(:user).where.not(users: { line_uid: nil })
    verified_users   = line_users.where(users: { phone_verified: true })
    @sms_verify_rate = line_users.count > 0 ? (verified_users.count.to_f / line_users.count * 100).round(1) : 0

    @recent_entries  = entries.includes(:user).order(created_at: :desc).limit(10)
  end

  def export_entries
    require 'csv'

    winners_only = params[:winners_only] == 'true'
    entries = @event.entries.includes(:user).order(created_at: :asc)
    entries = entries.win if winners_only

    label = winners_only ? '当選者' : '応募者全員'
    filename = "#{@event.title}_#{label}_#{Date.today}.csv"

    result_labels = { 'win' => '当選', 'lose' => '落選' }

    csv_data = CSV.generate(headers: true, encoding: 'UTF-8') do |csv|
      headers = ['応募日時', 'イベント名', 'LINE表示名', '電話番号']
      headers << '当落結果' unless winners_only
      csv << headers

      entries.each do |entry|
        row = [
          entry.created_at.in_time_zone('Asia/Tokyo').strftime('%Y-%m-%d %H:%M'),
          @event.title,
          entry.user&.display_name,
          entry.user&.phone_number
        ]
        row << (result_labels[entry.result] || '未抽選') unless winners_only
        csv << row
      end
    end

    send_data "﻿#{csv_data}",
              filename: filename,
              type: 'text/csv; charset=utf-8',
              disposition: 'attachment'
  end

  def draw_lottery
    cancel_lottery_job(@event)
    @event.execute_lottery!
    respond_to do |format|
      format.html { redirect_to admin_event_path(@event), notice: "抽選を実行しました。当選者 #{@event.winner_count} 名が選出されました。", status: :see_other }
      format.json { render json: { redirect_url: admin_event_path(@event) } }
    end
  rescue RuntimeError => e
    respond_to do |format|
      format.html { redirect_to admin_event_path(@event), alert: e.message, status: :see_other }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def scanner
    redirect_to admin_event_path(@event), alert: "このイベントはチェックイン機能が無効です" unless @event.checkin_enabled?
  end

  def verify_checkin
    token = params[:token].to_s.strip
    entry = @event.entries.find_by(checkin_token: token)

    if entry.nil?
      render json: { status: 'invalid', message: '無効なQRコードです' }, status: :unprocessable_entity
    elsif !entry.win?
      render json: { status: 'invalid', message: 'このQRコードは当選者のものではありません' }, status: :unprocessable_entity
    elsif entry.checked_in?
      render json: {
        status: 'already_checked_in',
        message: '既にチェックイン済みです',
        checked_in_at: l(entry.checked_in_at.in_time_zone('Asia/Tokyo'), format: :short),
        user_name: entry.user&.display_name
      }
    else
      entry.update!(checked_in_at: Time.current, status: :exchanged)
      render json: {
        status: 'success',
        message: 'チェックイン完了',
        user_name: entry.user&.display_name,
        picture_url: entry.user&.picture_url
      }
    end
  end

  # LINE通知ジョブの送信状況をポーリング確認用に返す
  def notification_status
    job = Object.const_get('GoodJob::Job')
                .where(job_class: 'LotteryNotificationJob')
                .where("serialized_params -> 'arguments' = ?", [@event.id].to_json)
                .order(created_at: :desc)
                .first

    status = if job.nil?
               'unknown'
             elsif job.finished_at.present? && job.error.blank?
               'success'
             elsif job.finished_at.present? && job.error.present?
               'error'
             else
               'pending'
             end

    render json: { status: status }
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
    params.require(:event).permit(:title, :description, :entry_start_at, :entry_end_at, :lottery_status, :winner_count, :image, :lottery_mode, :lottery_scheduled_at, :checkin_enabled)
  end

  def build_chart_range(period)
    case period
    when 'today'
      range  = Time.current.beginning_of_day..Time.current.end_of_day
      labels = (0..23).map { |h| format('%02d:00', h) }
      keys   = labels
    when 'week'
      start  = Time.current.beginning_of_week
      range  = start..Time.current.end_of_day
      days   = (start.to_date..Date.today).to_a
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    when 'month'
      start  = Time.current.beginning_of_month
      range  = start..Time.current.end_of_day
      days   = (start.to_date..Date.today).to_a
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    else
      days   = 6.downto(0).map { |i| i.days.ago.to_date }
      range  = days.last.beginning_of_day..Time.current.end_of_day
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    end
    [range, labels, keys]
  end

  def group_key(period)
    period == 'today' ? "TO_CHAR(created_at AT TIME ZONE 'Asia/Tokyo', 'HH24:00')" : "DATE(created_at AT TIME ZONE 'Asia/Tokyo')"
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
