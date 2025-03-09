class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  
  # ブックマーク一覧
  def index
    @bookmarks = current_user.bookmarks.order(created_at: :desc)
    
    # タグでフィルタリング
    if params[:tag].present?
      # ANY演算子を使わずにLIKE検索を使用
      @bookmarks = @bookmarks.where("tags::text LIKE ?", "%#{params[:tag]}%")
    end
    
    # 検索キーワードでフィルタリング
    @bookmarks = @bookmarks.search(params[:search]) if params[:search].present?
    
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
      @tags = @tags.sort_by { |tag| [-current_user.bookmarks.where("tags::text LIKE ?", "%#{tag}%").maximum(:created_at).to_i, tag] }
    when 'created_asc'
      @tags = @tags.sort_by { |tag| [current_user.bookmarks.where("tags::text LIKE ?", "%#{tag}%").minimum(:created_at).to_i, tag] }
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

    if @bookmark.save
      @bookmark.generate_description
      redirect_to bookmarks_path, notice: 'ブックマークを追加しました。'
    else
      # エラーメッセージを設定
      flash.now[:alert] = @bookmark.errors.full_messages.to_sentence
      
      # indexアクションで必要な変数を準備
      @bookmarks = current_user.bookmarks.order(created_at: :desc)
      @tags = current_user.bookmarks.flat_map(&:tags).uniq
      @tag_counts = {}
      current_user.bookmarks.each do |bookmark|
        bookmark.tags.each do |tag|
          @tag_counts[tag] ||= 0
          @tag_counts[tag] += 1
        end
      end
      
      # indexページにレンダリング（newではなく）
      render :index, status: :unprocessable_entity
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