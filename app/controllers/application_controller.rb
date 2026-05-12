class ApplicationController < ActionController::Base
  before_action :ensure_cookie_uuid

  private

  def ensure_cookie_uuid
    return if cookies[:cookie_uuid].present?

    cookies.permanent[:cookie_uuid] = { value: SecureRandom.uuid, httponly: true }
  end

  # Sorceryのrequire_loginが失敗した場合（エンドユーザー向けのみ使用）
  def not_authenticated
    redirect_to root_path, alert: 'ログインしてください'
  end

  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id])
  end
  helper_method :current_admin

  def require_admin_login
    return if current_admin

    redirect_to admin_login_path, alert: 'ログインしてください'
  end
end
