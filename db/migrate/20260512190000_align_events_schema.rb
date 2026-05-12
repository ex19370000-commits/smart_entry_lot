class AlignEventsSchema < ActiveRecord::Migration[7.0]
  def change
    # winner_count追加（旧ブランチでDB適用済みの場合はスキップ）
    add_column :events, :winner_count, :integer, null: false, default: 1 unless column_exists?(:events, :winner_count)

    # admin_id追加（nullable：権限階層実装時にFKを付与する想定）
    add_column :events, :admin_id, :bigint

    # カラム名をER図に合わせてリネーム
    rename_column :events, :start_at, :entry_start_at
    rename_column :events, :end_at, :entry_end_at
    rename_column :events, :status, :lottery_status

    # 抽選実行日時追加
    add_column :events, :lottery_executed_at, :datetime
  end
end
