class AddPublicTokenToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :public_token, :string
    add_index :events, :public_token, unique: true
  end
end
