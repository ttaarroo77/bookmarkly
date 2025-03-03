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

    respond_to do |format|
      if @bookmark.save
        @bookmark.generate_description
        format.turbo_stream { redirect_to bookmarks_path, notice: 'ブックマークを追加しました。' }
        format.html { redirect_to bookmarks_path, notice: 'ブックマークを追加しました。' }
      else
        # エラーメッセージを設定
        error_message = @bookmark.errors.full_messages.join(', ')
        flash.now[:alert] = error_message
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
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
    @bookmark = current_user.bookmarks.find(params[:id])
  end
  
  # StrongParameters
  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :tags_text)
  end
end