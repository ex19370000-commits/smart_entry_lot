class Admin < ApplicationRecord
  has_secure_password
  # 店舗アカウント削除時はイベント（と紐づく応募・閲覧ログ）も連鎖削除する
  has_many :events, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  enum :role, { owner: 0, store: 1 }, prefix: :role
end
