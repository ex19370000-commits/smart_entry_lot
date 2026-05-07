class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    # default: false, null: false を追記
    add_column :users, :admin, :boolean, default: false, null: false
  end
end