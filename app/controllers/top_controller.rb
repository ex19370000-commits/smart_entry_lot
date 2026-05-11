class TopController < ApplicationController
  skip_before_action :require_login, only: [:index], raise: false

  def index
    # liff.state がある場合は view の LIFF SDK がクライアント側でコードを処理する
  end
end
