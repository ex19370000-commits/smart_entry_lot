class Event < ApplicationRecord
  # Active Storageで画像を1枚紐付け
  has_one_attached :image
  # TODO: 応募機能（Entry）のテーブルとカラムが完成したらコメントアウトを外す
  # has_many :entries, dependent: :destroy

  # ステータス管理 (0:下書き, 1:公開, 2:終了)
  enum status: { draft: 0, published: 1, closed: 2 }

  # バリデーション
  validates :title, presence: true
  validates :description, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :status, presence: true
end
