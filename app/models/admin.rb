class Admin < ApplicationRecord
  has_secure_password
  has_many :events

  validates :email, presence: true, uniqueness: true

  enum :role, { owner: 0, store: 1 }, prefix: :role
end
