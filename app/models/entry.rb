class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :shop

  enum result: { lose: 0, win: 1 }
  enum status: { unexchanged: 0, exchanged: 1 }

  # カスタムバリデーションの追加
  validate :only_one_entry_per_day, on: :create

  private

  def only_one_entry_per_day
    # user が nil の場合は、そもそも belongs_to のバリデーションで弾かれるので、ここでは何もしない
    return if user.nil? 

    if user.entries.where(shop_id: shop_id, created_at: Time.zone.now.all_day).exists?
      errors.add(:base, "この店舗での抽選は1日1回までです")
    end
  end
end
