class Users::SessionsController < Devise::SessionsController
  respond_to :html, :json
  
  # ログアウト後の処理
  def destroy
    super do
      # JSON形式のリクエストの場合はヘッダーだけを返す
      return head :no_content if request.format.json?
    end
  end
end