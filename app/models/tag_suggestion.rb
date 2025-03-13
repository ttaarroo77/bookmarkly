class TagSuggestion < ApplicationRecord
  belongs_to :prompt

  validates :name, presence: true
  validates :name, uniqueness: { scope: :prompt_id }
  validates :confidence, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }

  # 信頼度の高い順にソートするスコープ
  scope :by_confidence, -> { order(confidence: :desc) }
  
  # 未適用のタグ候補を取得するスコープ
  scope :not_applied, -> { where(applied: false) }
end