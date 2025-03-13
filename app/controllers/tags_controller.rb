class TagsController < ApplicationController
  before_action :authenticate_user!
  
  def destroy
    @tag = current_user.tags.find(params[:id])
    
    if @tag.destroy
      # タグ削除後に未使用タグを削除（念のため）
      Tag.cleanup_unused_tags
      
      flash[:success] = "タグ「#{@tag.name}」を削除しました"
    else
      flash[:error] = "タグの削除に失敗しました"
    end
    
    redirect_to prompts_path
  end
  
  # 他のアクションがあればここに追加
end 