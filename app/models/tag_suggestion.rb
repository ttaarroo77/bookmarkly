class TagSuggestion < ApplicationRecord
  belongs_to :prompt

  validates :name, presence: true
  validates :name, uniqueness: { scope: :prompt_id }
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
end