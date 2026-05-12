class Admin::DashboardsController < ApplicationController
  before_action :require_admin_login

  layout 'admin'

  def index
    # 管理者専用のロジックをここに書く
  end
end
