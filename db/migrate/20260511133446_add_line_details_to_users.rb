class AddLineDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :line_user_id, :string
    add_column :users, :picture_url, :string
    
    # line_user_id で高速に検索でき、かつ重複しないようにインデックスを追加
    add_index :users, :line_user_id, unique: true
  end
end