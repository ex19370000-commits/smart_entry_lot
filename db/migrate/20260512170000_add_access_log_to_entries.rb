class AddAccessLogToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :ip_address, :string
    add_column :entries, :user_agent, :text

    add_index :entries, :ip_address
  end
end
