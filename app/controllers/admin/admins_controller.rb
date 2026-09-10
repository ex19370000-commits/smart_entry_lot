class Admin::AdminsController < ApplicationController
  before_action :require_admin_login
  before_action :require_owner
  layout 'admin'

  def index
    scope = Admin.role_store.includes(:events)

    @q = params[:q].to_s.strip
    scope = scope.where('display_name ILIKE :q OR email ILIKE :q', q: "%#{@q}%") if @q.present?

    @sort = %w[created_at display_name].include?(params[:sort]) ? params[:sort] : 'created_at'
    @direction = params[:direction] == 'asc' ? 'asc' : 'desc'
    @store_admins = scope.order(@sort => @direction)
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to admin_admins_path, notice: "店舗アカウント「#{@admin.display_name}」を発行しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    admin = Admin.role_store.find(params[:id])
    admin.destroy!
    redirect_to admin_admins_path, notice: "店舗アカウント「#{admin.display_name}」を削除しました", status: :see_other
  end

  private

  def require_owner
    redirect_to admin_events_path, alert: '権限がありません' unless current_admin.role_owner?
  end

  def admin_params
    params.require(:admin).permit(:email, :display_name, :password, :password_confirmation, :role)
  end
end
