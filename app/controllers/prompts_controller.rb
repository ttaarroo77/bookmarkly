class PromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  
  # プロンプト一覧
  def index
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
    
    # タグのソート（新規登録順のソートを削除）
    case params[:sort]
    when 'count_desc'
      @tags = @tags.sort_by { |tag| [-@tag_counts[tag.name], tag.name] }
    when 'count_asc'
      @tags = @tags.sort_by { |tag| [@tag_counts[tag.name], tag.name] }
    else
      # デフォルトは使用頻度の多い順
      @tags = @tags.sort_by { |tag| [-@tag_counts[tag.name], tag.name] }
    end
    
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
    @prompt = current_user.prompts.new(prompt_params)
    
    respond_to do |format|
      if @prompt.save
        # AI概要生成を開始
        @prompt.generate_description if @prompt.url.present?
        
        # タグ一覧と出現回数を再取得
        @prompts = current_user.prompts.order(created_at: :desc)
        @tags = current_user.tags
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
    params.require(:prompt).permit(:url, :title, :tags_text)
  end
end




# class PromptsController < ApplicationController
#   before_action :authenticate_user!
#   before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  
#   # プロンプト一覧
#   def index
#     @prompts = current_user.prompts.order(created_at: :desc)
    
#     # タグでフィルタリング
#     if params[:tag].present?
#       @prompts = @prompts.with_tag(params[:tag])
#     end
    
#     # 検索キーワードでフィルタリング
#     @prompts = @prompts.search(params[:search]) if params[:search].present?
    
#     # タグの一覧を取得
#     @tags = current_user.tags.reload # 明示的に再読み込み
    
#     # タグの出現回数をカウント
#     @tag_counts = {}
#     @tags.each do |tag|
#       @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
#     end
    
#     # タグのソート（新規登録順のソートを削除）
#     case params[:sort]
#     when 'count_desc'
#       @tags = @tags.sort_by { |tag| [-@tag_counts[tag.name], tag.name] }
#     when 'count_asc'
#       @tags = @tags.sort_by { |tag| [@tag_counts[tag.name], tag.name] }
#     else
#       # デフォルトは使用頻度の多い順
#       @tags = @tags.sort_by { |tag| [-@tag_counts[tag.name], tag.name] }
#     end
    
#     # 新規プロンプト用のインスタンス
#     @prompt = Prompt.new
#   end
  
#   # プロンプトの詳細表示
#   def show
#   end
  
#   # 新規プロンプトフォーム
#   def new
#     @prompt = Prompt.new
#   end
  
#   # プロンプト編集フォーム
#   def edit
#   end
  
#   # プロンプト作成
#   def create
#     @prompt = current_user.prompts.new(prompt_params)
    
#     respond_to do |format|
#       if @prompt.save
#         # AI概要生成を開始
#         @prompt.generate_description if @prompt.url.present?
        
#         # タグ一覧と出現回数を再取得
#         @prompts = current_user.prompts.order(created_at: :desc)
#         @tags = current_user.tags
#         @tag_counts = {}
#         @tags.each do |tag|
#           @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
#         end
        
#         format.html { redirect_to prompts_path, notice: 'プロンプトが正常に作成されました。' }
#         format.json { render :show, status: :created, location: @prompt }
#       else
#         # エラー時は再度フォームを表示
#         @prompts = current_user.prompts.order(created_at: :desc)
#         @tags = current_user.tags
        
#         # タグの出現回数をカウント
#         @tag_counts = {}
#         @tags.each do |tag|
#           @tag_counts[tag.name] = tag.prompts.where(user_id: current_user.id).count
#         end
        
#         format.html { render :index }
#         format.json { render json: @prompt.errors, status: :unprocessable_entity }
#       end
#     end
#   end
  
#   # プロンプト更新
#   def update
#     respond_to do |format|
#       if @prompt.update(prompt_params)
#         format.html { redirect_to prompt_path(@prompt), notice: 'プロンプトが正常に更新されました。' }
#         format.json { render :show, status: :ok, location: @prompt }
#       else
#         format.html { render :edit }
#         format.json { render json: @prompt.errors, status: :unprocessable_entity }
#       end
#     end
#   end
  
#   # プロンプト削除
#   def destroy
#     @prompt.destroy
#     respond_to do |format|
#       format.html { redirect_to prompts_path, notice: 'プロンプトが正常に削除されました。' }
#       format.json { head :no_content }
#     end
#   end
  
#   private
  
#   # プロンプトの取得
#   def set_prompt
#     @prompt = current_user.prompts.find(params[:id])
#   end
  
#   # ストロングパラメータ
#   def prompt_params
#     params.require(:prompt).permit(:url, :title, :tags_text)
#   end
# end