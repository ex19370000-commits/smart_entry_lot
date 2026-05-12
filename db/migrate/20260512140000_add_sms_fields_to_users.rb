class AddSmsFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean, default: false, null: false
    add_column :users, :sms_code, :string
    add_column :users, :sms_code_sent_at, :datetime

    add_index :users, :phone_number, unique: true
  end
end
