class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :entries, dependent: :destroy
  has_one :sms_verification, dependent: :destroy

  # LINEログイン(line_uidがある)以外の場合のみ、emailとパスワードを必須にする
  validates :email, presence: true, uniqueness: true, unless: -> { line_uid.present? }
  validates :password, length: { minimum: 3 }, if: -> { new_record? && line_uid.blank? }
  validates :password, confirmation: true, if: -> { new_record? && line_uid.blank? }
  validates :password_confirmation, presence: true, if: -> { new_record? && line_uid.blank? }

  validates :phone_number, uniqueness: true, allow_nil: true
end