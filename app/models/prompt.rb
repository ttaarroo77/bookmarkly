# app/models/prompt.rb - プロンプトモデル


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
  attr_accessor :tags_text
  after_save :save_tags, if: -> { !@tags_text.nil? }
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    @tags_text = text
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
  
  # AIタグ提案の開始
  def generate_tag_suggestions
    update(ai_processing_status: :processing)
    GenerateTagSuggestionsJob.perform_later(id)
  end

  private

  def normalize_url
    return if url.blank?
    self.url = url.strip.downcase
    # URLがhttp(s)://で始まっていない場合、https://を追加
    self.url = "https://#{url}" unless url.start_with?('http://', 'https://')
  end

  def save_tags
    return if @tags_text.blank?
    
    # 既存のタグを一旦クリア
    self.tags.clear
    
    # タグを保存
    tag_names = @tags_text.split(/,|\s+/).map(&:strip).uniq.reject(&:blank?)
    tag_names.each do |name|
      next if name.blank?
      tag = Tag.find_or_create_by(name: name.downcase, user_id: self.user_id)
      self.tags << tag unless self.tags.include?(tag)
    end
  end

  def cleanup_unused_tags
    # プロンプト削除後に未使用タグをクリーンアップ
    Tag.cleanup_unused_tags if Tag.respond_to?(:cleanup_unused_tags)
  end
end