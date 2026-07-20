class Admin::DashboardsController < ApplicationController
  include Chartable

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

    sms_counts       = User.where.not(line_uid: nil).group(:phone_verified).count
    sms_total        = sms_counts.values.sum
    sms_verified     = sms_counts[true] || 0
    @sms_verify_rate = sms_total > 0 ? (sms_verified.to_f / sms_total * 100).round(1) : 0

    @active_events  = event_scope.where(lottery_status: [:published, :closed]).includes(:entries).order(:entry_end_at)
    @recent_entries = entry_scope.includes(:user, :event).order(created_at: :desc).limit(10)
    @event_ranking  = event_scope.joins(:entries).group(:id).order('COUNT(entries.id) DESC').limit(5).select('events.*, COUNT(entries.id) AS entries_count')
  end

end
