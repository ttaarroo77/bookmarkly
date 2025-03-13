class AddSuggestionToTagSuggestionHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :tag_suggestion_histories, :suggestion, :text, null: false, default: ""
  end
end 