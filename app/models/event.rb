class Event < ApplicationRecord
  # Active Storageで画像を1枚紐付け
  has_one_attached :image
  has_many :entries, dependent: :destroy
  has_many :page_views, dependent: :destroy
  belongs_to :admin, optional: true
  
  # 自動でランダムな一意のトークンを生成する設定
  has_secure_token :public_token

  # 抽選ステータス管理 (0:下書き, 1:公開, 2:終了)
  enum lottery_status: { draft: 0, published: 1, closed: 2 }

  # 抽選モード (0:応募終了後即抽選, 1:スケジューリング抽選)
  enum lottery_mode: { auto: 0, scheduled: 1 }

  validates :lottery_scheduled_at, presence: true, if: :scheduled?

  # バリデーション
  validates :title, presence: true
  validates :description, presence: true
  validates :entry_start_at, presence: true
  validates :entry_end_at, presence: true
  validates :lottery_status, presence: true
  validates :winner_count, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # 本番環境と開発環境でURLのドメインを切り替えるメソッド
  def public_url
    if Rails.env.production?
      "https://smart-entry-lot.onrender.com/events/#{public_token}"
    else
      # 変更箇所：localhost:3000 を ngrokの固定ドメインに書き換え
      "https://skinless-caterer-gecko.ngrok-free.dev/events/#{public_token}"
    end
  end

  def already_drawn?
    lottery_executed_at.present?
  end

  # winner_count件をランダム選出し、結果を一括更新するトランザクション処理
  def execute_lottery!
    raise "既に抽選済みです" if already_drawn?

    all_entries = entries.to_a
    raise "応募者がいません" if all_entries.empty?

    winner_ids = all_entries.sample(winner_count).map(&:id)

    ActiveRecord::Base.transaction do
      entries.where(id: winner_ids).update_all(result: Entry.results[:win])
      entries.where.not(id: winner_ids).update_all(result: Entry.results[:lose])
      update!(lottery_executed_at: Time.current)
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
