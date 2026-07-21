class AddPerformanceIndexes < ActiveRecord::Migration[7.0]
  def change
    # 抽選結果フィルタ（entries.win スコープ・当選者カウント）
    add_index :entries, :result, if_not_exists: true

    # 管理者別イベント絞り込み（current_admin.events）
    add_index :events, :admin_id, if_not_exists: true

    # ステータスフィルタ（published/closed の絞り込み）
    add_index :events, :lottery_status, if_not_exists: true
  end
end
