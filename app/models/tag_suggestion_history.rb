class TagSuggestionHistory < ApplicationRecord
  belongs_to :prompt
  belongs_to :user
  
  # 評価の定義 - Rails 7の正しい構文
  enum :rating, { dislike: -1, neutral: 0, like: 1 }, default: :neutral
  
  # 同じプロンプトに対する同じ提案内容は記録しない
  validates :suggestion, uniqueness: { scope: [:prompt_id, :user_id] }
  
  # プロンプトに対する提案履歴を取得
  def self.for_prompt(prompt)
    where(prompt_id: prompt.id).order(created_at: :desc)
  end
  
  # 提案を記録するメソッド
  def self.record(prompt, suggestion, user)
    # 同じ提案がすでに存在する場合は作成しない
    return if exists?(prompt_id: prompt.id, suggestion: suggestion, user_id: user.id)
    
    create(
      prompt_id: prompt.id,
      user_id: user.id,
      suggestion: suggestion,
      suggested_tags: suggestion,
      suggested_at: Time.current # 現在時刻を設定
    )
  end
end