class User < ApplicationRecord
  authenticates_with_sorcery!
  
  has_many :entries, dependent: :destroy

  # ...既存のバリデーションなど
end