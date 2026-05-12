class ApplicationController < ActionController::Base
  before_action :ensure_cookie_uuid

  private

  def ensure_cookie_uuid
    return if cookies[:cookie_uuid].present?

    cookies.permanent[:cookie_uuid] = { value: SecureRandom.uuid, httponly: true }
  end

  # Sorceryのデフォルトメソッドを上書き（未ログイン時の動作）
  def not_authenticated
    redirect_to admin_login_path, alert: "ログインしてください"
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end
