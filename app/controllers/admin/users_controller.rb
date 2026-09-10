class Admin::UsersController < ApplicationController
  before_action :require_admin_login
  before_action :set_user, only: %i[show destroy block unblock]

  layout 'admin'

  def index
    @q = params[:q].to_s.strip
    @users = scoped_users
    if @q.present?
      @users = @users.where(
        'display_name ILIKE :q OR phone_number ILIKE :q OR line_uid ILIKE :q',
        q: "%#{@q}%"
      )
    end

    @sort = %w[created_at display_name].include?(params[:sort]) ? params[:sort] : 'created_at'
    @direction = params[:direction] == 'asc' ? 'asc' : 'desc'
    @users = @users.order(@sort => @direction)
  end

  def show
    @entries = @user.entries.includes(:event).order(created_at: :desc)
  end

  def destroy
    @user.destroy!
    redirect_to admin_users_path, notice: "ユーザー「#{@user.display_name}」を削除しました", status: :see_other
  end

  def block
    @user.update!(blocked_at: Time.current)
    redirect_to admin_user_path(@user), notice: "ユーザー「#{@user.display_name}」をブロックしました"
  end

  def unblock
    @user.update!(blocked_at: nil)
    redirect_to admin_user_path(@user), notice: "ユーザー「#{@user.display_name}」のブロックを解除しました"
  end

  def export
    require 'csv'

    users = scoped_users.order(created_at: :asc)
    filename = "ユーザー一覧_#{Date.today}.csv"

    csv_data = CSV.generate(headers: true, encoding: 'UTF-8') do |csv|
      csv << %w[登録日時 LINE表示名 電話番号 SMS認証 応募件数 状態]
      users.each do |user|
        csv << [
          user.created_at.in_time_zone('Asia/Tokyo').strftime('%Y-%m-%d %H:%M'),
          user.display_name,
          user.phone_number,
          (user.phone_verified? ? '認証済み' : '未認証'),
          user.entries.size,
          (user.blocked? ? 'ブロック中' : '有効')
        ]
      end
    end

    send_data csv_data, filename: filename, type: 'text/csv; charset=UTF-8'
  end

  private

  def scoped_users
    if current_admin.role_store?
      User.joins(:entries).where(entries: { event_id: current_admin.events.select(:id) }).distinct
    else
      User.all
    end
  end

  def set_user
    @user = scoped_users.find(params[:id])
  end
end
