class FixSuggestedTagsInTagSuggestionHistories < ActiveRecord::Migration[7.0]
  def change
    # suggested_tagsカラムのNOT NULL制約を削除
    change_column_null :tag_suggestion_histories, :suggested_tags, true
    
    # または、デフォルト値を空文字列に設定
    # change_column_default :tag_suggestion_histories, :suggested_tags, ""
  end
end 