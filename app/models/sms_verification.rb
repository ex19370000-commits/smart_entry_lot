class SmsVerification < ApplicationRecord
  belongs_to :user

  validates :code, :sent_at, presence: true
end
