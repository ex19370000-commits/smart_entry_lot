class Shop < ApplicationRecord
  has_many :entries, dependent: :destroy
end
