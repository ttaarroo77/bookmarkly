class Prompt < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :tag_suggestions, dependent: :destroy
  
  # バリデーション
  validates :url, presence: true, 
                 uniqueness: { 
                   scope: :user_id, 
                   message: 'はすでに登録されています',
                   case_sensitive: false 
                 }
  validates :title, presence: true
  
  # URLを正規化するコールバック
  before_validation :normalize_url
  
  # タグをカンマ区切りの文字列として取得するゲッター
  def tags_text
    tags.map(&:name).join(', ') if tags.present?
  end
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    return if text.blank?
    
    # 既存のタグ関連をクリア
    self.tags.clear
    
    # 新しいタグを追加
    text.split(',').map(&:strip).reject(&:empty?).uniq.each do |tag_name|
      # ユーザーが存在する場合のみタグを作成
      if self.user.present?
        tag = self.user.tags.find_or_initialize_by(name: tag_name.downcase)
        self.tags << tag unless self.tags.include?(tag)
      end
    end
  end
  
  # タグで検索するスコープ
  scope :with_tag, ->(tag_name) {
    if tag_name.present?
      joins(:tags).where("tags.name = ?", tag_name.downcase)
    end
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
    # 非同期処理に変更
    update(ai_processing_status: :processing)
    GenerateDescriptionJob.perform_later(id)
  end

  private

  def normalize_url
    return if url.blank?
    self.url = url.strip.downcase
    # URLがhttp(s)://で始まっていない場合、https://を追加
    self.url = "https://#{url}" unless url.start_with?('http://', 'https://')
  end
end