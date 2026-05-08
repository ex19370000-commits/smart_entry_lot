# db/seeds.rb

puts "=== シードデータの作成を開始します ==="

# 1. 既存データの削除（外部キー制約がある場合は、子データから先に消す必要があります）
# 依存関係（EntryがShopやUserに紐付いている場合）を考慮して Entry から削除
Entry.destroy_all if defined?(Entry)
Shop.destroy_all
User.destroy_all

# 2. 一般テストユーザーの作成
User.create!(
  name: "テストユーザー",
  email: "test@example.com",
  password: "password",
  password_confirmation: "password"
)

# 3. 店舗データの作成（葛飾区周辺）
shops_data = [
  { name: "スターバックス 葛飾店", address: "東京都葛飾区立石..." },
  { name: "セブンイレブン 葛飾駅前店", address: "東京都葛飾区立石..." },
  { name: "イトーヨーカドー 四つ木店", address: "東京都葛飾区四つ木..." }
]

shops_data.each do |data|
  Shop.create!(data)
end

# 4. 管理者ユーザーの作成
# adminフラグをtrueにし、emailの重複を避けるため一箇所にまとめます
User.create!(
  name: "管理者ユーザー",
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  role: :admin # または admin: true。お使いのスキーマ（enumかbooleanか）に合わせてください
)

puts "=== シードデータの作成が完了しました！ ==="
puts "ユーザー: #{User.count}件"
puts "店舗: #{Shop.count}件"