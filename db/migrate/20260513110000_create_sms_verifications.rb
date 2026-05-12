class CreateSmsVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_verifications do |t|
      # 1ユーザーにつき未検証レコードは1件のみ許容するためユニーク制約
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :code, null: false
      t.datetime :sent_at, null: false

      t.timestamps
    end

    # usersテーブルから一時コード系カラムを削除（phone_number・phone_verifiedは永続属性なので残す）
    remove_column :users, :sms_code, :string
    remove_column :users, :sms_code_sent_at, :datetime
  end
end
