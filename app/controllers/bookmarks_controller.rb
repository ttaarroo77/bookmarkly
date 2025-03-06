class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  
  # ブックマーク一覧
  def index
    @bookmarks = current_user.bookmarks.order(created_at: :desc)
    
    # タグによるフィルタリング
    if params[:tag].present?
      @bookmarks = @bookmarks.with_tag(params[:tag])
    end
    
    # タグの一覧を取得（タグクラウド用）
    @tags = current_user.bookmarks.flat_map(&:tags).uniq
    
    # タグの使用回数を集計
    @tag_counts = {}
    current_user.bookmarks.each do |bookmark|
      bookmark.tags.each do |tag|
        @tag_counts[tag] ||= 0
        @tag_counts[tag] += 1
      end
    end
    
    # タグのソート
    case params[:sort]
    when 'count_desc'
      @tags = @tags.sort_by { |tag| [-@tag_counts[tag], tag] }
    when 'count_asc'
      @tags = @tags.sort_by { |tag| [@tag_counts[tag], tag] }
    when 'created_desc'
      @tags = @tags.sort_by { |tag| [-current_user.bookmarks.where("? = ANY(tags)", tag).maximum(:created_at).to_i, tag] }
    when 'created_asc'
      @tags = @tags.sort_by { |tag| [current_user.bookmarks.where("? = ANY(tags)", tag).minimum(:created_at).to_i, tag] }
    end
    
    # 新規ブックマーク用のインスタンス
    @bookmark = Bookmark.new
  end
  
  # ブックマークの詳細表示
  def show
  end
  
  # 新規ブックマークフォーム
  def new
    @bookmark = Bookmark.new
  end
  
  # ブックマーク編集フォーム
  def edit
  end
  
  # ブックマーク作成
  def create
    @bookmark = current_user.bookmarks.build(bookmark_params)
    
    # 同じURLのブックマークが既に存在するか確認
    existing_bookmark = current_user.bookmarks.find_by(url: @bookmark.url)
    
    respond_to do |format|
      if existing_bookmark
        # 既存のブックマークが見つかった場合
        format.html { 
          flash[:alert] = "このURLは既にブックマークに登録されています。"
          redirect_to edit_bookmark_path(existing_bookmark)
        }
        format.json { render json: { status: 'error', message: 'このURLは既に登録されています', existing_bookmark: existing_bookmark }, status: :unprocessable_entity }
      elsif @bookmark.save
        @bookmark.generate_description
        format.html { redirect_to bookmarks_path, notice: "ブックマークを追加しました。" }
        format.json { render json: { status: 'success', bookmark: @bookmark }, status: :created }
        format.turbo_stream
      else
        # エラーメッセージをログに出力
        Rails.logger.error("Bookmark save error: #{@bookmark.errors.full_messages.join(', ')}")
        
        # 新規作成フォームを表示
        @tags = Tag.all
        format.html { 
          flash.now[:alert] = @bookmark.errors.full_messages.join(', ')
          render :new, status: :unprocessable_entity 
        }
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end
  
  # ブックマーク更新
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to bookmarks_path, notice: 'ブックマークを更新しました。' }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # ブックマーク削除
  def destroy
    @bookmark.destroy
    respond_to do |format|
      format.html { redirect_to bookmarks_path, notice: 'ブックマークを削除しました。' }
      format.json { head :no_content }
    end
  end
  
  def check_exists
    url = params[:url]
    Rails.logger.info("Checking if URL exists: #{url}")
    
    if url.blank?
      Rails.logger.warn("URL parameter is blank")
      return render json: { error: "URL is required" }, status: :bad_request
    end
    
    # 認証チェックを緩和（拡張機能からのリクエスト用）
    if current_user.nil?
      Rails.logger.warn("User not authenticated")
      return render json: { error: "Authentication required", requires_login: true }, status: :unauthorized
    end
    
    begin
      exists = current_user.bookmarks.exists?(url: url)
      Rails.logger.info("URL exists check result: #{exists}")
      render json: { exists: exists }
    rescue => e
      Rails.logger.error("Error checking URL existence: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      render json: { error: "An error occurred" }, status: :internal_server_error
    end
  end
  
  # 拡張機能からのブックマーク保存用アクション
  def save_from_extension
    # 認証チェック
    unless current_user
      return render json: { error: "Authentication required" }, status: :unauthorized
    end
    
    @bookmark = current_user.bookmarks.build(bookmark_params)
    
    if @bookmark.save
      render json: { 
        status: 'success', 
        message: 'ブックマークを保存しました', 
        bookmark: @bookmark 
      }, status: :created
    else
      render json: { 
        status: 'error', 
        message: @bookmark.errors.full_messages.join(', '), 
        errors: @bookmark.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  # ブックマークを取得
  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  end
  
  # StrongParameters
  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :tags_text)
  end
end