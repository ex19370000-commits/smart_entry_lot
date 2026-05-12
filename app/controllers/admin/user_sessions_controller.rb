class Admin::UserSessionsController < ApplicationController
  def new; end

  def create
    admin = Admin.find_by(email: params[:email])
    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to admin_dashboard_path, notice: 'ログインしました'
    else
      flash.now[:alert] = 'ログインに失敗しました'
      render :new
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to admin_login_path, notice: 'ログアウトしました'
  end
end
