class AddLotterySchedulingToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :lottery_mode, :integer, default: 0, null: false
    add_column :events, :lottery_scheduled_at, :datetime
    add_column :events, :scheduled_job_id, :string
  end
end
