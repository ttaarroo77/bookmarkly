class PromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  
  # プロンプト一覧
  def index
    # 常に新しい順（created_at: :desc）で表示するように固定
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
  end
  
  # 新規プロンプトフォーム
  def new
    @prompt = Prompt.new
  end
  
  # プロンプト編集フォーム
  def edit
  end
  
  # プロンプト作成
  def create
    @prompt = current_user.prompts.new(prompt_params.except(:tags_text))
    
    respond_to do |format|
      if @prompt.save
        # プロンプト保存後にタグを設定
        if params[:prompt][:tags_text].present?
          begin
            @prompt.tags_text = params[:prompt][:tags_text]
            @prompt.save
          rescue => e
            Rails.logger.error "タグ保存エラー: #{e.message}"
            @prompt.errors.add(:tags_text, "の保存に失敗しました")
            raise ActiveRecord::Rollback
          end
        end
        
        # AI概要生成を開始
        @prompt.generate_description if @prompt.url.present?
        
        # タグ一覧と出現回数を再取得
        @prompts = current_user.prompts.order(created_at: :desc)
        @tags = current_user.tags.reload
        @tag_counts = {}
        @tags.each do |tag|
          @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
        end
        
        format.html { redirect_to prompts_path, notice: 'プロンプトが正常に作成されました。' }
        format.json { render :show, status: :created, location: @prompt }
      else
        # エラー時は再度フォームを表示
        @prompts = current_user.prompts.order(created_at: :desc)
        @tags = current_user.tags
        
        # タグの出現回数をカウント
        @tag_counts = {}
        @tags.each do |tag|
          @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
        end
        
        format.html { render :index }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # プロンプト更新
  def update
    respond_to do |format|
      if @prompt.update(prompt_params)
        format.html { redirect_to prompts_path, notice: 'プロンプトが正常に更新されました。' }
        format.json { render :index, status: :ok, location: prompts_path }
      else
        format.html { render :edit }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # プロンプト削除
  def destroy
    @prompt.destroy
    respond_to do |format|
      format.html { redirect_to prompts_path, notice: 'プロンプトが正常に削除されました。' }
      format.json { head :no_content }
    end
  end
  
  private
  
  # プロンプトの取得
  def set_prompt
    @prompt = current_user.prompts.find(params[:id])
  end
  
  # ストロングパラメータ
  def prompt_params
    params.require(:prompt).permit(:url, :title, :tags_text, :description)
  end
end