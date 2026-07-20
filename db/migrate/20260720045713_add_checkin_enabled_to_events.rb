class AddCheckinEnabledToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :checkin_enabled, :boolean, default: false, null: false
  end
end
