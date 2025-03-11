class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  
  before_validation :normalize_name
  after_commit :check_for_cleanup, on: [:update, :destroy]
  after_save :cleanup_if_unused
  
  # タグが使用されているプロンプト数を確認し、未使用タグを削除するクラスメソッド
  def self.cleanup_unused_tags
    Tag.left_joins(:prompts)
       .group(:id)
       .having('COUNT(prompts.id) = 0')
       .destroy_all
  end
  
  private
  
  def normalize_name
    self.name = name.downcase.strip if name.present?
  end

  def check_for_cleanup
    # タグに関連するプロンプトがなくなった場合、削除
    self.destroy if self.persisted? && self.prompts.count == 0
  end

  def cleanup_if_unused
    # 保存後に未使用の場合は削除
    self.destroy if self.prompts.count == 0
  end
end 