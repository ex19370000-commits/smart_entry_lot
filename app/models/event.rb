class Event < ApplicationRecord
  # Active Storageで画像を1枚紐付け
  has_one_attached :image
  has_many :entries, dependent: :destroy
  
  # 自動でランダムな一意のトークンを生成する設定
  has_secure_token :public_token

  # ステータス管理 (0:下書き, 1:公開, 2:終了)
  enum status: { draft: 0, published: 1, closed: 2 }

  # バリデーション
  validates :title, presence: true
  validates :description, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :status, presence: true

  # 本番環境と開発環境でURLのドメインを切り替えるメソッド
  def public_url
    if Rails.env.production?
      "https://smart-entry-lot.onrender.com/events/#{public_token}"
    else
      # 変更箇所：localhost:3000 を ngrokの固定ドメインに書き換え
      "https://skinless-caterer-gecko.ngrok-free.dev/events/#{public_token}"
    end
  end

  # QRコードのSVGデータを生成するメソッド
  def qr_code_svg
    qrcode = RQRCode::QRCode.new(public_url)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    )
  end
end
