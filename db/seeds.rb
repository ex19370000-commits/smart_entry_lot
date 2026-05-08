# 既存データの削除（実行するたびにデータが重複しないように掃除します）
Entry.destroy_all
Shop.destroy_all
User.destroy_all

# テストユーザーの作成
# password_confirmation がエラーになる場合は password のみでOKです
user = User.create!(
  name: "テストユーザー",
  email: "test@example.com",
  password: "password"
)

# 店舗データの作成（葛飾区周辺のイメージ）
shops_data = [
  { name: "スターバックス 葛飾店", address: "東京都葛飾区立石..." },
  { name: "セブンイレブン 葛飾駅前店", address: "東京都葛飾区立石..." },
  { name: "イトーヨーカドー 四つ木店", address: "東京都葛飾区四つ木..." }
]

shops_data.each do |data|
  Shop.create!(data)
end

puts "=== シードデータの作成が完了しました！ ==="
puts "ユーザー: #{User.count}件"
puts "店舗: #{Shop.count}件"

User.create!(
  name: "管理者ユーザー",
  email: "admin@example.com",
  password: "password",
  admin: true # ここで管理者に設定
)

puts "管理者ユーザーを作成しました！"

User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')