class Admin::DashboardsController < ApplicationController
  before_action :require_admin_login

  layout 'admin'

  def index
    event_scope = current_admin.role_store? ? current_admin.events : Event.all
    entry_scope = current_admin.role_store? ? Entry.where(event_id: current_admin.events.select(:id)) : Entry.all

    @period = params[:period] || '7days'
    range, @labels, keys = build_chart_range(@period)

    pv_scope        = current_admin.role_store? ? PageView.where(event_id: current_admin.events.select(:id)) : PageView.all
    scoped_pv       = pv_scope.where(created_at: range)
    scoped_entries  = entry_scope.where(created_at: range)

    raw_access      = scoped_pv.group(group_key(@period)).distinct.count(:cookie_uuid).transform_keys(&:to_s)
    raw_entries     = scoped_entries.group(group_key(@period)).count.transform_keys(&:to_s)

    @chart_access   = keys.map { |k| raw_access[k] || 0 }
    @chart_entries  = keys.map { |k| raw_entries[k] || 0 }

    total_access    = pv_scope.distinct.count(:cookie_uuid)
    total_entries   = entry_scope.count
    @entry_rate     = total_access > 0 ? (total_entries.to_f / total_access * 100).round(1) : 0

    line_users       = User.where.not(line_uid: nil)
    verified_users   = line_users.where(phone_verified: true)
    @sms_verify_rate = line_users.count > 0 ? (verified_users.count.to_f / line_users.count * 100).round(1) : 0

    @active_events  = event_scope.where(lottery_status: [:published, :closed]).includes(:entries).order(:entry_end_at)
    @recent_entries = entry_scope.includes(:user, :event).order(created_at: :desc).limit(10)
    @event_ranking  = event_scope.joins(:entries).group(:id).order('COUNT(entries.id) DESC').limit(5).select('events.*, COUNT(entries.id) AS entries_count')
  end

  private

  # [range, 表示用ラベル配列, DB集計キー配列] を返す
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
end
