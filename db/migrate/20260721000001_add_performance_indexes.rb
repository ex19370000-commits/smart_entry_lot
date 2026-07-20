class AddPerformanceIndexes < ActiveRecord::Migration[7.0]
  def change
    # 抽選結果フィルタ（entries.win スコープ・当選者カウント）
    add_index :entries, :result, unless: index_exists?(:entries, :result)

    # 管理者別イベント絞り込み（current_admin.events）
    add_index :events, :admin_id, unless: index_exists?(:events, :admin_id)

    # ステータスフィルタ（published/closed の絞り込み）
    add_index :events, :lottery_status, unless: index_exists?(:events, :lottery_status)
  end
end
