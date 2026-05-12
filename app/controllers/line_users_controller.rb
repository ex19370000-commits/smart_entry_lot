require 'net/http'

class LineUsersController < ApplicationController
  # LIFF から呼ばれる JSON API のため CSRF をスキップ（LINE アクセストークン検証で身元を確認）
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    return render json: { status: 'error', message: 'access_token is required' }, status: :bad_request if params[:access_token].blank?

    # LINE サーバーでトークンを検証し、正規の line_user_id を取得
    line_user_id = verify_line_token(params[:access_token])
    return render json: { status: 'error', message: 'Invalid LINE access token' }, status: :unauthorized unless line_user_id

    user = User.find_or_initialize_by(line_user_id: line_user_id)
    user.name = params[:name]
    user.picture_url = params[:picture_url]

    # Sorcery の email NOT NULL 制約を回避するため新規作成時のみダミー値をセット
    if user.new_record?
      user.email = "line_#{line_user_id}@example.com"
      user.password = SecureRandom.hex(10)
      user.password_confirmation = user.password
    end

    if user.save
      auto_login(user)
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def verify_line_token(access_token)
    # LIFFのPKCEトークンはVerify APIにaudが含まれないため、Profile APIで検証する
    uri = URI("https://api.line.me/v2/profile")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    response = http.request(request)
    Rails.logger.info("[LINE profile] status=#{response.code}")
    return nil unless response.is_a?(Net::HTTPSuccess)

    profile = JSON.parse(response.body)
    profile['userId'] # 検証済みの LINE ユーザー ID
  rescue StandardError => e
    Rails.logger.error("[LINE profile] error: #{e.message}")
    nil
  end
end
