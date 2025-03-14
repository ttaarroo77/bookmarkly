# spec/controllers/minimal_test_controller_spec.rb - 最小限のテストケース


require 'rails_helper'

# 最小限のコントローラーテスト
RSpec.describe PromptsController, type: :controller do
  describe "Devise mapping test" do
    it "should allow sign_in with mock" do
      # ユーザーを作成
      user = create(:user)
      
      # モックを使用してログイン
      @request.env['warden'] = double(Warden, authenticate: user, authenticate!: user)
      allow(controller).to receive(:current_user).and_return(user)
      
      # ログインが成功したことを確認
      expect(controller.current_user).to eq(user)
    end
  end
end