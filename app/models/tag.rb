class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  
  before_validation :normalize_name
  
  def normalize_name
    self.name = name.downcase.strip if name.present?
  end
  
  def usage_count
    prompts.count
  end
  
  scope :search, ->(query) {
    where("name ILIKE ?", "%#{query}%") if query.present?
  }
  
  scope :sorted_by, ->(sort_type) {
    case sort_type
    when 'count_desc'
      joins(:prompts)
        .group('tags.id')
        .order('COUNT(prompts.id) DESC')
    when 'count_asc'
      joins(:prompts)
        .group('tags.id')
        .order('COUNT(prompts.id) ASC')
    else
      order(name: :asc)
    end
  }

  # タグが使用されているプロンプト数を確認し、未使用タグを削除するクラスメソッド
  def self.cleanup_unused_tags
    Tag.left_joins(:prompts).group(:id).having('COUNT(prompts.id) = 0').destroy_all
  end
  
  # プロンプトとタグの関連付けが変更された後に実行
  after_commit :check_for_cleanup, on: [:update, :destroy]
  
  private
  
  def check_for_cleanup
    # タグに関連するプロンプトがなくなった場合、削除
    self.destroy if self.persisted? && self.prompts.count == 0
  end
end 