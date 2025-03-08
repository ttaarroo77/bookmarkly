class Bookmark < ApplicationRecord
  belongs_to :user
  
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
    tags.join(', ') if tags.present?
  end
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    self[:tags] = text.present? ? text.split(',').map(&:strip).reject(&:empty?).uniq : []
  end
  
  # タグを配列として取得
  def tags
    if self[:tags].is_a?(String)
      # JSON文字列から配列に変換
      begin
        JSON.parse(self[:tags])
      rescue
        []
      end
    else
      self[:tags] || []
    end
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
    # 非同期処理でAIによる説明文生成を行う
    GenerateBookmarkSummaryWorker.perform_async(id)
  end

  private

  def normalize_url
    return if url.blank?
    self.url = url.strip.downcase
    # URLがhttp(s)://で始まっていない場合、https://を追加
    self.url = "https://#{url}" unless url.start_with?('http://', 'https://')
  end
end