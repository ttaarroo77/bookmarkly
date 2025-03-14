# app/models/tag.rb - タグモデル（関連）


class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :prompts

  # バリデーション - ユーザーごとに一意のタグ名
  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user_id, presence: true
  
  before_save :downcase_name
  
  # 無限再帰を避けるため、インスタンスのコールバックを削除
  # after_commit :check_for_cleanup, on: [:update, :destroy]
  # after_save :cleanup_if_unused
  
  # タグが使用されているプロンプト数を確認し、未使用タグを削除するクラスメソッド
  def self.cleanup_unused_tags
    self.left_joins(:prompts).where(prompts: { id: nil }).destroy_all
  end
  
  private
  
  def downcase_name
    self.name = name.downcase if name.present?
  end

  # 以下のメソッドはコールバックから呼ばれなくなったので削除
  # def check_for_cleanup
  #   # タグに関連するプロンプトがなくなった場合、削除
  #   self.destroy if self.prompts.reload.empty?
  # end

  # def cleanup_if_unused
  #   # 保存後に未使用の場合は削除
  #   self.destroy if self.prompts.count == 0
  # end
end 