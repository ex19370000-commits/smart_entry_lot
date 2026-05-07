class Admin::DashboardsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    # 管理者専用のロジックをここに書く
  end
end
