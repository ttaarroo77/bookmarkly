module ControllerMacros
  # コントローラーテスト用ログインヘルパー
  def login_user
    # テスト前に一度だけ実行（コントローラー全体に対して）
    before(:each) do
      # Deviseのマッピングを設定する前に明示的にリクエストオブジェクトを設定
      @request.env["devise.mapping"] = Devise.mappings[:user]
      # テストユーザーを作成
      user = FactoryBot.create(:user)
      # サインイン
      sign_in user
    end
  end
end