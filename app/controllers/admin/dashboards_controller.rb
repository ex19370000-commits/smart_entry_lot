class Admin::DashboardsController < ApplicationController
  before_action :require_admin_login

  layout 'admin'

  def index
    # 権限によってスコープを切り替え
    event_scope = current_admin.role_store? ? current_admin.events : Event.all
    entry_scope = current_admin.role_store? ? Entry.where(event_id: current_admin.events.select(:id)) : Entry.all

    # 過去7日間の日別集計
    @daily_entries = entry_scope
                       .where(created_at: 7.days.ago.beginning_of_day..)
                       .group("DATE(created_at)")
                       .count
    @daily_access = entry_scope
                      .where(created_at: 7.days.ago.beginning_of_day..)
                      .group("DATE(created_at)")
                      .distinct
                      .count(:cookie_uuid)

    # 応募率（全期間）
    total_access  = entry_scope.distinct.count(:cookie_uuid)
    total_entries = entry_scope.count
    @entry_rate = total_access > 0 ? (total_entries.to_f / total_access * 100).round(1) : 0

    # SMS認証完了率（LINE登録済みユーザー対象）
    line_users       = User.where.not(line_uid: nil)
    verified_users   = line_users.where(phone_verified: true)
    @sms_verify_rate = line_users.count > 0 ? (verified_users.count.to_f / line_users.count * 100).round(1) : 0

    # イベント一覧（公開・終了、応募締切順）
    @active_events = event_scope.where(lottery_status: [:published, :closed]).includes(:entries).order(:entry_end_at)

    # 直近の応募アクティビティ
    @recent_entries = entry_scope.includes(:user, :event).order(created_at: :desc).limit(10)

    # イベント別応募数ランキング（上位5件）
    @event_ranking = event_scope
                       .joins(:entries)
                       .group(:id)
                       .order('COUNT(entries.id) DESC')
                       .limit(5)
                       .select('events.*, COUNT(entries.id) AS entries_count')
  end
end
