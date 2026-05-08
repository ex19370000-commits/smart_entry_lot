Rails.application.routes.draw do
  # トップページ
  root 'top#index'

  # 静的ページ（利用規約・プライバシーポリシー）
  get 'terms', to: 'static_pages#terms'
  get 'privacy_policy', to: 'static_pages#privacy_policy'

  # 管理者専用ルート
  namespace :admin do
    get 'events/index'
    get 'events/new'
    get 'events/create'
    get 'events/show'
    get 'events/edit'
    get 'events/update'
    get 'events/destroy'
    # ログイン・ログアウト
    get 'login', to: 'user_sessions#new'
    post 'login', to: 'user_sessions#create'
    delete 'logout', to: 'user_sessions#destroy'
    
    # ダッシュボード
    get 'dashboard', to: 'dashboards#index'
    resources :events
  end
end
