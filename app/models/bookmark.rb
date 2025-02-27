class Bookmark < ApplicationRecord
  belongs_to :user
  
  # バリデーション
  validates :url, presence: true, format: { with: URI::regexp(%w(http https)), message: "は有効なURLではありません" }
  validates :title, presence: true
  
  # タグをカンマ区切りの文字列として取得するゲッター
  def tags_text
    tags&.join(', ') || ''
  end
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    self.tags = text.present? ? text.split(',').map(&:strip).reject(&:empty?).uniq : []
  end
  
  # タグを配列として取得
  def tags
    return [] if self[:tags].nil?
    return self[:tags] if self[:tags].is_a?(Array)
    # JSON文字列から配列に変換
    JSON.parse(self[:tags])
  end
  
  # タグで検索するスコープ
  scope :with_tag, ->(tag) {
    where("? = ANY(tags)", tag) if tag.present?
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
    GenerateBookmarkSummaryJob.perform_later(id)
  end
end