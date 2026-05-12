class Admin::AccessLogsController < ApplicationController
  before_action :require_admin_login

  layout 'admin'

  def index
    @entries = Entry.includes(:user, :event)
                    .where.not(ip_address: nil)
                    .order(created_at: :desc)
                    .limit(200)
  end
end
