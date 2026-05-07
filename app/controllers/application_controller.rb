class ApplicationController < ActionController::Base

private

  # 管理者かどうかをチェックし、管理者でなければトップページへリダイレクトさせる
  def require_admin
    # ログインしていない、またはログインしていても管理者でない場合
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end
