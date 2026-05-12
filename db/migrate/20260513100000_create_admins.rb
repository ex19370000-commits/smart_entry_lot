class CreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :display_name

      t.timestamps
    end

    add_index :admins, :email, unique: true

    # adminsテーブルに切り出したため不要になる
    remove_column :users, :admin, :boolean
  end
end
