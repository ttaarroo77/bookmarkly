class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  # バリデーション - ユーザーごとに一意のタグ名
  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user_id, presence: true
  
  before_save :normalize_name
  after_commit :check_for_cleanup, on: [:update, :destroy]
  
  # タグが使用されているプロンプト数を確認し、未使用タグを削除するクラスメソッド
  def self.cleanup_unused_tags
    Tag.left_joins(:prompts)
       .group(:id)
       .having('COUNT(prompts.id) = 0')
       .destroy_all
  end
  
  private
  
  def normalize_name
    self.name = name.strip.downcase if name.present?
  end

  def check_for_cleanup
    # タグに関連するプロンプトがなくなった場合、削除
    self.destroy if self.persisted? && self.prompts.count == 0 && should_cleanup?
  end

  def should_cleanup?
    # シードデータの場合はクリーンアップしない
    !Rails.env.development? || !caller.any? { |c| c.include?('db/seeds.rb') }
  end
end 