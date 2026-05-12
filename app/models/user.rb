class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :entries, dependent: :destroy

  # LINEログイン(line_user_idがある)以外の場合のみ、emailとパスワードを必須にする
  validates :email, presence: true, uniqueness: true, unless: -> { line_user_id.present? }
  validates :password, length: { minimum: 3 }, if: -> { new_record? && line_user_id.blank? }
  validates :password, confirmation: true, if: -> { new_record? && line_user_id.blank? }
  validates :password_confirmation, presence: true, if: -> { new_record? && line_user_id.blank? }

  validates :phone_number, uniqueness: true, allow_nil: true
end