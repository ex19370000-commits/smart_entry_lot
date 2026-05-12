class AddEventIdToEntries < ActiveRecord::Migration[7.0]
  def change
    add_reference :entries, :event, null: false, foreign_key: true
    change_column_null :entries, :shop_id, true
  end
end
