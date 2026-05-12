# db/seeds.rb

puts "=== シードデータの作成を開始します ==="

# 1. 既存データの削除
Entry.destroy_all if defined?(Entry) && ActiveRecord::Base.connection.table_exists?('entries')
Shop.destroy_all  if defined?(Shop)  && ActiveRecord::Base.connection.table_exists?('shops')
User.destroy_all  if defined?(User)  && ActiveRecord::Base.connection.table_exists?('users')
Admin.destroy_all if defined?(Admin) && ActiveRecord::Base.connection.table_exists?('admins')

# 2. 管理者の作成（adminsテーブル）
Admin.create!(
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  display_name: "管理者ユーザー"
)

# 3. 一般テストユーザーの作成
User.create!(
  display_name: "テストユーザー",
  email: "test@example.com",
  password: "password",
  password_confirmation: "password"
)

# 4. 店舗データの作成
if defined?(Shop) && ActiveRecord::Base.connection.table_exists?('shops')
  shops_data = [
    { name: "スターバックス 葛飾店", address: "東京都葛飾区立石..." },
    { name: "セブンイレブン 葛飾駅前店", address: "東京都葛飾区立石..." },
    { name: "イトーヨーカドー 四つ木店", address: "東京都葛飾区四つ木..." }
  ]

  shops_data.each do |data|
    shop = Shop.new
    shop.name = data[:name] if Shop.columns_hash.key?('name')
    shop.address = data[:address] if Shop.columns_hash.key?('address')
    shop.save!
  end
end

puts "=== シードデータの作成が完了しました！ ==="
puts "管理者: #{Admin.count}件"
puts "ユーザー: #{User.count}件"
puts "店舗: #{Shop.count rescue 0}件"
