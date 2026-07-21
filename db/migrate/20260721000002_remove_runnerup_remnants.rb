class RemoveRunnerupRemnants < ActiveRecord::Migration[7.0]
  def change
    # 繰り上げ当選機能はキャンセルのため関連テーブル・カラムを削除
    drop_table :runnerup_lotteries, if_exists: true
    remove_column :events, :runnerup_enabled, :boolean, if_exists: true
  end
end
