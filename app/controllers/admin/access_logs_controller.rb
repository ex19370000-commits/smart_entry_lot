class Admin::AccessLogsController < ApplicationController
  before_action :require_admin_login

  layout 'admin'

  def index
    scope = Entry.includes(:user, :event).where.not(ip_address: nil)
    scope = scope.where(event_id: current_admin.events.select(:id)) if current_admin.role_store?
    @entries = scope.order(created_at: :desc).limit(200)
  end
end
