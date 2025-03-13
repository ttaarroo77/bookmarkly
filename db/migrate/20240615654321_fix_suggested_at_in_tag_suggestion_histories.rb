class FixSuggestedAtInTagSuggestionHistories < ActiveRecord::Migration[7.0]
  def change
    # suggested_atカラムのNOT NULL制約を削除
    change_column_null :tag_suggestion_histories, :suggested_at, true
    
    # または、デフォルト値を現在時刻に設定
    # change_column_default :tag_suggestion_histories, :suggested_at, -> { 'CURRENT_TIMESTAMP' }
  end
end 