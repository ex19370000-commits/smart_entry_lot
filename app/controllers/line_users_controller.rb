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
    uri = URI("https://api.line.me/oauth2/v2.1/verify?access_token=#{URI.encode_www_form_component(access_token)}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    payload = JSON.parse(response.body)

    # aud が自サービスのチャンネル ID と一致することを確認（トークン置換攻撃の対策）
    return nil unless payload['aud'] == ENV['LINE_CHANNEL_ID']

    payload['sub'] # 検証済みの LINE ユーザー ID
  rescue StandardError
    nil
  end
end
