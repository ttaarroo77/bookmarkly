class PromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:show, :edit, :update, :destroy, :apply_tag_suggestion, :apply_tags, :rate_tag_suggestion]
  
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
    @prompt = current_user.prompts.find(params[:id])
    
    # タグ提案を取得
    @suggested_tags = TagSuggestionService.suggest_tags(@prompt)
    
    # タグ提案履歴を保存（既に同じ提案がある場合は保存しない）
    if @suggested_tags.present?
      TagSuggestionHistory.record(@prompt, @suggested_tags, current_user)
    end
    
    # タグ提案履歴を取得
    @suggestion_histories = TagSuggestionHistory.for_prompt(@prompt)
  end
  
  # 新規プロンプトフォーム
  def new
    @prompt = Prompt.new
    # URLパラメータがある場合はURLのみ設定し、AIタグ候補を取得
    if params[:url].present?
      @prompt.url = params[:url]
      @tag_suggestions = AiTagSuggester.new(current_user).suggest_tags_for_url(@prompt.url)
    end
  end

  # プロンプト編集フォーム
  def edit
  end
  
  # プロンプト作成
  def create
    @prompt = current_user.prompts.build(prompt_params)
    
    if @prompt.save
      # タグ候補生成ジョブを実行
      GenerateTagSuggestionsJob.perform_later(@prompt.id)
      
      # AI説明文生成（実装されている場合）
      @prompt.generate_description if @prompt.respond_to?(:generate_description)
      
      flash[:success] = "プロンプトを保存しました。AIによるタグ候補を生成中です。"
      redirect_to prompts_path
    else
      # URLが重複している場合は既存のプロンプトへのリンクを表示するため、
      # 既存のプロンプトを@existing_promptとして渡す
      if @prompt.errors[:url].include?("は既に登録されています")
        @existing_prompt = current_user.prompts.find_by(url: @prompt.url)
      end
      render :new, status: :unprocessable_entity
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
  
  # タグを適用するアクション
  def apply_tags
    @prompt = current_user.prompts.find(params[:id])
    tags_string = params[:tags]
    
    if tags_string.present?
      # トランザクションを使用して整合性を保証
      ActiveRecord::Base.transaction do
        # カンマで区切られたタグを配列に変換し、空白を削除
        tag_names = tags_string.split(',').map(&:strip).reject(&:empty?)
        
        # 既存のタグをクリア
        @prompt.tags.clear
        
        # 新しいタグを追加
        tag_names.each do |tag_name|
          # ユーザーに紐づくタグを作成
          tag = current_user.tags.find_or_create_by!(name: tag_name.downcase)
          # 関連付けを追加
          @prompt.tags << tag unless @prompt.tags.include?(tag)
        end
        
        flash[:success] = "タグを更新しました"
      end
    else
      flash[:alert] = "タグを入力してください"
    end
    
    redirect_to @prompt
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = "タグの適用に失敗しました: #{e.message}"
    redirect_to @prompt
  end
  
  # プロンプト更新
  def update
    @prompt = current_user.prompts.find(params[:id])
    
    # トランザクションを使用して、すべての処理が成功するか失敗するかを保証
    ActiveRecord::Base.transaction do
      if @prompt.update(prompt_params)
        redirect_to @prompt, notice: 'プロンプトが更新されました。'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # バリデーションエラーなどの処理
    Rails.logger.error "プロンプト更新エラー: #{e.message}"
    flash.now[:alert] = "プロンプトの更新に失敗しました: #{e.message}"
    render :edit, status: :unprocessable_entity
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
  
  # タグ提案の評価
  def rate_tag_suggestion
    history_id = params[:history_id]
    rating = params[:rating].to_i
    
    history = TagSuggestionHistory.find_by(id: history_id, prompt_id: @prompt.id)
    
    if history
      # 評価を更新（現在と同じ評価なら評価を解除）
      new_rating = history.rating == rating ? 0 : rating
      history.update(rating: new_rating)
      
      # フィードバックを追加（オプション）
      history.update(feedback: params[:feedback]) if params[:feedback].present?
      
      flash[:success] = "評価を更新しました"
    else
      flash[:error] = "履歴が見つかりません"
    end
    
    redirect_to @prompt
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
    params.require(:prompt).permit(:url, :title, :description, :tags_text)
  end
end