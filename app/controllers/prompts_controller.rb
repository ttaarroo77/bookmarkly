# app/controllers/prompts_controller.rb - テスト対象のコントローラー


class PromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:show, :edit, :update, :destroy, :apply_tag_suggestion]
  
  # プロンプト一覧
  def index
    # 常に新しい順（created_at: :desc）で表示するように固定し、ソートパラメータを無視
    @prompts = current_user.prompts.order(created_at: :desc)
    
    # タグでフィルタリング
    if params[:tag].present?
      @prompts = @prompts.with_tag(params[:tag])
    end
    
    # 検索キーワードでフィルタリング
    @prompts = @prompts.search(params[:search]) if params[:search].present?
    
    # タグの一覧を取得
    @tags = current_user.tags.reload # 明示的に再読み込み
    
    # タグの出現回数をカウント
    @tag_counts = {}
    @tags.each do |tag|
      @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
    end
    
    # タグのソート（使用頻度の多い順）
    @tags = @tags.sort_by { |tag| [-@tag_counts[tag.name], tag.name] }
    
    # 新規プロンプト用のインスタンス
    @prompt = Prompt.new
  end
  
  # プロンプトの詳細表示
  def show
    # タグ候補が生成されていない場合は生成を開始
    if @prompt.tag_suggestions.empty? && @prompt.url.present?
      GenerateTagSuggestionsJob.perform_later(@prompt.id)
      flash.now[:info] = "タグ候補を生成中です。しばらくしてからページを更新してください。"
    end
  end
  
  # 新規プロンプトフォーム
  def new
    @prompt = current_user.prompts.new
  end

  # プロンプト編集フォーム
  def edit
    @prompt = current_user.prompts.find(params[:id])
    # タグ提案を取得
    @tag_suggestions = @prompt.tag_suggestions.order(count: :desc).limit(10)
  end
  
  # プロンプト作成
  def create
    @prompt = current_user.prompts.new(prompt_params)

    respond_to do |format|
      if @prompt.save
        # AIによるタグ提案を開始
        @prompt.generate_tag_suggestions if @prompt.respond_to?(:generate_tag_suggestions)
        
        format.html { redirect_to @prompt, notice: 'プロンプトを作成しました。' }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render :new }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # タグ候補の適用
  def apply_tag_suggestion
    suggestion = @prompt.tag_suggestions.find(params[:suggestion_id])
    
    # ユーザーのタグを検索または作成
    tag = current_user.tags.find_or_create_by(name: suggestion.name.downcase)
    
    # プロンプトにタグを追加（既に追加されている場合は何もしない）
    unless @prompt.tags.include?(tag)
      @prompt.tags << tag
      suggestion.update(applied: true)
      flash[:success] = "タグ「#{tag.name}」を適用しました"
    else
      flash[:info] = "タグ「#{tag.name}」は既に適用されています"
    end
    
    redirect_to @prompt
  end
  
  # プロンプト更新
  def update
    if @prompt.update(prompt_params)
      # タグの更新後に未使用タグを削除
      Tag.cleanup_unused_tags if Tag.respond_to?(:cleanup_unused_tags)
      
      # 修正: flash[:notice]を使用し、詳細ページにリダイレクト
      flash[:notice] = "プロンプトを更新しました"
      redirect_to @prompt  # 詳細ページにリダイレクト
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # プロンプト削除
  def destroy
    begin
      @prompt = current_user.prompts.find(params[:id])
      success = @prompt.destroy
      
      if success
        # プロンプト削除後に未使用タグを削除
        Tag.cleanup_unused_tags if Tag.respond_to?(:cleanup_unused_tags)
        message = "プロンプトを削除しました"
      else
        message = "プロンプトの削除に失敗しました"
      end
    rescue => e
      Rails.logger.error "Error deleting prompt: #{e.message}"
      success = false
      message = "プロンプトの削除中にエラーが発生しました"
    end
    
    # フォーマットに応じてレスポンスを返す
    respond_to do |format|
      format.html do
        flash[:success] = message if success
        flash[:error] = message unless success
        redirect_to prompts_path
      end
      format.json do
        if success
          render json: { success: true, message: message }, status: :ok
        else
          render json: { success: false, message: message }, status: :unprocessable_entity
        end
      end
      format.any do
        head :ok
      end
    end
  end
  
  def generate_description
    @prompt = current_user.prompts.find(params[:id])
    @prompt.generate_description
    redirect_to @prompt, notice: 'AI説明文の生成を開始しました。しばらくお待ちください。'
  end
  
  def generate_tag_suggestions
    @prompt = current_user.prompts.find(params[:id])
    @prompt.generate_tag_suggestions
    redirect_to @prompt, notice: 'AIタグ提案の生成を開始しました。しばらくお待ちください。'
  end
  
  private
  
  # プロンプトの取得
  def set_prompt
    begin
      @prompt = current_user.prompts.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "指定されたプロンプトは存在しないか、既に削除されています"
      redirect_to prompts_path
    end
  end
  
  # ストロングパラメータ
  def prompt_params
    params.require(:prompt).permit(:url, :title, :tags_text, :description)
  end
end