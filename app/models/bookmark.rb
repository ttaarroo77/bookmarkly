class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags
  
  # バリデーション
  validates :url, presence: true, 
                 format: { with: URI::regexp(%w(http https)), message: "は有効なURLではありません" }
  # 同じユーザーの同じURLの登録を防ぐ
  validates :url, uniqueness: { scope: :user_id, message: "は既に登録されています" }
  validates :title, presence: true
  
  # URLを正規化するコールバック
  before_validation :normalize_url
  
  # タグをカンマ区切りの文字列として取得するゲッター
  def tags_text
    tags&.join(', ') || ''
  end
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    return if text.nil?
    
    # 既存のタグ関連をクリア
    self.bookmark_tags.clear if persisted?
    
    # 新しいタグを設定
    tag_names = text.split(',').map(&:strip).reject(&:empty?).uniq
    
    self.tags = tag_names.map do |name|
      Tag.find_or_create_by(name: name)
    end
  end
  
  # タグで検索するスコープを修正
  scope :with_tag, ->(tag_name) {
    joins(:tags).where(tags: { name: tag_name }) if tag_name.present?
  }
  
  # キーワードで検索するスコープ
  scope :search, ->(keyword) {
    where("title ILIKE ? OR url ILIKE ?", "%#{keyword}%", "%#{keyword}%") if keyword.present?
  }

  # AI処理ステータスの定義
  enum :ai_processing_status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }, default: :pending

  # AI概要生成の開始
  def generate_description
    ::GenerateBookmarkSummaryWorker.perform_async(id)
  end

  private

  def normalize_url
    return if url.blank?
    self.url = url.strip.downcase
    # URLがhttp(s)://で始まっていない場合、https://を追加
    self.url = "https://#{url}" unless url.start_with?('http://', 'https://')
  end
end