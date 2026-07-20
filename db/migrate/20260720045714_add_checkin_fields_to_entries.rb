class AddCheckinFieldsToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :checkin_token, :string
    add_column :entries, :checked_in_at, :datetime
    add_index  :entries, :checkin_token, unique: true
  end
end
