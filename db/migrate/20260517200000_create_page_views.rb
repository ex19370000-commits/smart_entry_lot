class CreatePageViews < ActiveRecord::Migration[7.0]
  def change
    create_table :page_views do |t|
      t.references :event, null: false, foreign_key: true
      t.string :cookie_uuid
      t.timestamps
    end

    add_index :page_views, [:event_id, :cookie_uuid]
    add_index :page_views, :created_at
  end
end
