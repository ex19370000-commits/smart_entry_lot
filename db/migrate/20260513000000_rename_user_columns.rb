class RenameUserColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :line_user_id, :line_uid
    rename_column :users, :name, :display_name
  end
end
