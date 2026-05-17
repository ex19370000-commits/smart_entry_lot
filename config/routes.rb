Rails.application.routes.draw do
  # ヘルスチェック（Render.com のスリープ対策 ping 先）
  get 'health', to: proc { [200, {}, ['ok']] }

  # トップページ
  root 'top#index'

  # 静的ページ
  get 'terms', to: 'static_pages#terms'
  get 'privacy_policy', to: 'static_pages#privacy_policy'

  # 管理者専用ルート
  namespace :admin do
    # /admin へのアクセスをダッシュボードに紐付け
    # 未ログイン時は Sorcery の require_login 等によって /admin/login へ遷移します
    root to: 'dashboards#index'

    # ログイン・ログアウト
    get 'login', to: 'user_sessions#new'
    post 'login', to: 'user_sessions#create'
    delete 'logout', to: 'user_sessions#destroy'

    # ダッシュボード
    get 'dashboard', to: 'dashboards#index'

    # イベント管理（resources を使えば index, new, create 等が自動で定義されます）
    resources :events do
      member do
        post :draw_lottery
      end
    end

    # アクセスログ（不正検知）
    resources :access_logs, only: %i[index]

    # 店舗アカウント発行（owner のみ）
    resources :admins, only: %i[index new create destroy]
  end
  
  # 一般応募者用のルーティング（IDではなく public_token で検索する）
  resources :events, param: :public_token, only: %i[show]

  # 一般ユーザーのログアウト
  delete 'logout', to: 'user_sessions#destroy'

  # LINEユーザー登録用APIのルーティング
  resources :line_users, only: %i[create]

  # 応募
  resources :entries, only: %i[create]

  # SMS認証
  resources :sms_verifications, only: %i[new create] do
    collection do
      get  :verify
      post :confirm
      post :reset_for_demo
    end
  end
end
