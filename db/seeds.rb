# db/seeds.rb

puts "=== シードデータの作成を開始します ==="

# 1. 既存データの削除
# 外部キー制約を考慮し、関連データがあれば先に消す
Entry.destroy_all if defined?(Entry)
Shop.destroy_all if defined?(Shop)
User.destroy_all

# 2. 一般テストユーザーの作成
User.create!(
  name: "テストユーザー",
  email: "test@example.com",
  password: "password"
)

# 3. 店舗データの作成
shops_data = [
  { name: "スターバックス 葛飾店", address: "東京都葛飾区立石..." },
  { name: "セブンイレブン 葛飾駅前店", address: "東京都葛飾区立石..." },
  { name: "イトーヨーカドー 四つ木店", address: "東京都葛飾区四つ木..." }
]

shops_data.each do |data|
  Shop.create!(data)
end

# 4. 管理者ユーザーの作成
# role か admin か、プロジェクトの仕様に合わせて片方を選んでください
User.create!(
  name: "管理者ユーザー",
  email: "admin@example.com",
  password: "password",
  role: :admin # もしここでエラーが出るなら 'admin: true' に書き換えてください
)

puts "=== シードデータの作成が完了しました！ ==="
puts "ユーザー: #{User.count}件"
puts "店舗: #{Shop.count}件"