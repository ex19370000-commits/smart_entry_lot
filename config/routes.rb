Rails.application.routes.draw do
  root 'top#index'

  # 管理者専用ルート
  namespace :admin do
    get 'user_sessions/new'
    get 'user_sessions/create'
    get 'user_sessions/destroy'
    # ログイン・ログアウト
    get 'login', to: 'user_sessions#new'
    post 'login', to: 'user_sessions#create'
    delete 'logout', to: 'user_sessions#destroy'
    
    # ダッシュボード
    get 'dashboard', to: 'dashboards#index'
  end
end
