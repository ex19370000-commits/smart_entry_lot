class Admin::UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])

    # ユーザーが存在し、かつ「管理者」である場合のみ許可
    if @user && @user.admin?
      redirect_to admin_dashboard_path, notice: 'ログインしました'
    else
      # 万が一、一般ユーザーがメアド登録されていてログインしようとした場合は弾く
      logout 
      flash.now[:alert] = 'ログインに失敗しました、または権限がありません'
      render :new
    end
  end

  def destroy
    logout
    redirect_to admin_login_path, notice: 'ログアウトしました'
  end
end
