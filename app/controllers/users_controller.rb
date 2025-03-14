class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  
  # マイページ表示
  def show
    # 現在のユーザーのプロンプトを取得
    @prompts = @user.prompts.order(created_at: :desc)
  end
  
  def edit
    # 編集ページの表示
    # 現在のユーザー情報を@userに格納済み
  end
  
  def update
    if @user.update(user_params)
      redirect_to mypage_path, notice: 'プロフィールを更新しました'
    else
      render :edit
    end
  end
  
  private
  
  def set_user
    @user = current_user
  end
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
end