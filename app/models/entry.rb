class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :shop

  # 抽選結果の定義（0: 落選, 1: 当選）
  enum result: { lose: 0, win: 1 }
  # 景品交換ステータス（0: 未交換, 1: 交換済み）
  enum status: { unexchanged: 0, exchanged: 1 }
end
