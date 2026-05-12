class AddDuplicateEntryBlock < ActiveRecord::Migration[7.0]
  def change
    # 同一ユーザー・同一イベントへの複数応募をDBレベルで防止
    add_index :entries, [:user_id, :event_id], unique: true

    # ブラウザ単位での重複検知用
    add_column :entries, :cookie_uuid, :string
    add_index :entries, [:cookie_uuid, :event_id]
  end
end
