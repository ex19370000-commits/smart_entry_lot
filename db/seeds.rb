# db/seeds.rb

puts "=== シードデータの作成を開始します ==="

# 1. 既存データの削除
Entry.destroy_all if defined?(Entry) && ActiveRecord::Base.connection.table_exists?('entries')
Shop.destroy_all  if defined?(Shop)  && ActiveRecord::Base.connection.table_exists?('shops')
User.destroy_all  if defined?(User)  && ActiveRecord::Base.connection.table_exists?('users')

# 2. 一般テストユーザーの作成
User.create!(
  name: "テストユーザー",
  email: "test@example.com",
  password: "password"
)

# 3. 店舗データの作成
# カラム名が違ってもエラーにならないよう、最低限の項目で作成
if defined?(Shop) && ActiveRecord::Base.connection.table_exists?('shops')
  shops_data = [
    { name: "スターバックス 葛飾店", address: "東京都葛飾区立石..." },
    { name: "セブンイレブン 葛飾駅前店", address: "東京都葛飾区立石..." },
    { name: "イトーヨーカドー 四つ木店", address: "東京都葛飾区四つ木..." }
  ]

  shops_data.each do |data|
    # columns_hash.key? でカラムの存在を確認しながら入れる
    shop = Shop.new
    shop.name = data[:name] if Shop.columns_hash.key?('name')
    shop.address = data[:address] if Shop.columns_hash.key?('address')
    shop.save!
  end
end

# 4. 管理者ユーザーの作成（ここが重要！）
admin_email = "admin@example.com"
admin = User.find_or_initialize_by(email: admin_email)
admin.name = "管理者ユーザー"
admin.password = "password"

# カラム名が 'admin' か 'role' か、あるいはどちらも無いかを確認してセット
if User.columns_hash.key?('admin')
  admin.admin = true
elsif User.columns_hash.key?('role')
  # 文字列かシンボルか不明なため、モデルの定義に合わせやすいよう文字列で試行
  admin.role = "admin"
end

admin.save!

puts "=== シードデータの作成が完了しました！ ==="
puts "ユーザー: #{User.count}件"
puts "店舗: #{Shop.count rescue 0}件"