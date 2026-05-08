FactoryBot.define do
  factory :event do
    title { "MyString" }
    description { "MyText" }
    start_at { "2026-05-08 15:54:27" }
    end_at { "2026-05-08 15:54:27" }
    status { 1 }
  end
end
