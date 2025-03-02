class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  
  # ブックマーク一覧
  def index
    @bookmarks = current_user.bookmarks.order(created_at: :desc)
    
    # 新規ブックマーク用のインスタンスを作成
    @bookmark = current_user.bookmarks.build
    


    # デバッグ用：重複チェック
    urls = @bookmarks.map(&:url)
    duplicate_urls = urls.select{ |url| urls.count(url) > 1 }.uniq
    if duplicate_urls.any?
      Rails.logger.debug "重複URL: #{duplicate_urls.inspect}"
      # 重複を除去（一時的な対応）
      @bookmarks = @bookmarks.to_a.uniq(&:url)
    end



    # タグによるフィルタリング
    if params[:tag].present?
      # タグの前後の引用符を削除
      clean_tag = params[:tag].gsub(/^"|"$/, '').strip
      
      # 配列型に対して@>演算子を使用
      @bookmarks = @bookmarks.where("tags::text[] @> ARRAY[?]::text[]", clean_tag)
    end
    
    # 検索クエリによるフィルタリング
    if params[:query].present?
      query = "%#{params[:query]}%"
      # 検索クエリでは配列型に対して適切な演算子を使用
      @bookmarks = @bookmarks.where("title ILIKE ? OR url ILIKE ? OR tags::text[] @> ARRAY[?]::text[]", 
                                   query, query, params[:query])
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
      # 修正: tagsが既に配列型の場合
      @tags = @tags.sort_by do |tag|
        [-current_user.bookmarks.where("tags @> ARRAY[?]::text[]", tag).maximum(:created_at).to_i, tag]
      end
    when 'created_asc'
      # 修正: tagsが既に配列型の場合
      @tags = @tags.sort_by do |tag|
        [current_user.bookmarks.where("tags @> ARRAY[?]::text[]", tag).minimum(:created_at).to_i, tag]
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @bookmarks }
    end
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
    
    # 既存のブックマークを検索
    existing_bookmark = current_user.bookmarks.find_by(url: @bookmark.url)
    
    if existing_bookmark
      # 既存ブックマークが見つかった場合
      respond_to do |format|
        format.html {
          flash[:notice] = "このURLは既に登録されています。既存のブックマークを更新しますか？"
          flash[:existing_bookmark_id] = existing_bookmark.id
          redirect_to edit_bookmark_path(existing_bookmark)
        }
        format.json { render json: { status: 'duplicate', bookmark_id: existing_bookmark.id } }
      end
    else
      # 新規ブックマークの場合
      if @bookmark.save
        # AI処理を開始
        @bookmark.generate_description if Rails.env.production?
        
        respond_to do |format|
          format.html { redirect_to bookmarks_path, notice: 'ブックマークが正常に作成されました。' }
          format.json { render json: @bookmark, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @bookmark.errors, status: :unprocessable_entity }
        end
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
  
  private
  
  # ブックマークを取得
  def set_bookmark
    begin
      @bookmark = current_user.bookmarks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "指定されたブックマークが見つかりませんでした。"
      redirect_to bookmarks_path
    end
  end
  
  # StrongParameters
  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :tags_text)
  end
end