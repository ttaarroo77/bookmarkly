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
  
  # タグテキストの仮想属性
  attr_accessor :tags_text
  
  # タグテキストを設定するメソッド
  def tags_text
    @tags_text || tags.map(&:name).join(', ')
  end
  
  # タグテキストからタグを設定するメソッド
  def tags_text=(text)
    @tags_text = text
  end
  
  # タグテキストを保存するメソッド
  def save_tags
    return unless @tags_text.present?
    
    # 既存のタグ関連付けをクリア
    self.tags.clear
    
    # タグテキストを分割して処理
    tag_names = @tags_text.split(',').map(&:strip).reject(&:blank?)
    
    tag_names.each do |tag_name|
      # ユーザーに紐づくタグを検索または作成
      tag = user.tags.find_or_create_by!(name: tag_name.downcase)
      # 関連付けを追加
      self.tags << tag unless self.tags.include?(tag)
    end
  end
  
  # コールバックでタグを保存
  after_save :save_tags, if: -> { @tags_text.present? }
  
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