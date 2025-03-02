class Bookmark < ApplicationRecord
  belongs_to :user
  
  # バリデーション
  validates :url, presence: true, 
          format: { with: URI::regexp(%w(http https)), message: "は有効なURLではありません" }, 
          uniqueness: { scope: :user_id, message: "は既に登録されています" }
  validates :title, presence: true
  
  # タグを配列として取得
  def tags
    return [] if self[:tags].nil?
    
    if self[:tags].is_a?(Array)
      # 配列の各要素を処理
      self[:tags].map do |tag|
        if tag.is_a?(String) && tag.include?('"')
          # 引用符を含む文字列の場合、JSONとして解析を試みる
          begin
            # 引用符を含む場合、JSONとして解析
            if tag.start_with?('[') || tag.start_with?('"')
              cleaned_tag = tag.gsub(/^\[|\]$/, '').strip
              # 先頭と末尾の引用符を削除
              cleaned_tag = cleaned_tag.gsub(/^"|"$/, '')
              # エスケープされた引用符を通常の引用符に変換
              cleaned_tag.gsub(/\\"/, '"')
            else
              tag
            end
          rescue
            tag
          end
        else
          tag
        end
      end
    elsif self[:tags].is_a?(String)
      # 文字列の場合はカンマで分割
      self[:tags].split(',').map(&:strip)
    else
      []
    end
  end
  
  # タグをカンマ区切りの文字列として取得するゲッター
  def tags_text
    tags.join(', ')
  end
  
  # タグをカンマ区切りの文字列からセットするセッター
  def tags_text=(text)
    self.tags = text.present? ? text.split(',').map(&:strip).reject(&:empty?).uniq : []
  end
  
  # タグで検索するスコープ
  scope :with_tag, ->(tag) {
    where("tags @> ARRAY[?]::text[]", tag) if tag.present?
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