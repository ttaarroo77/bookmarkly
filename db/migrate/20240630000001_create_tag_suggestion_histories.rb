class CreateTagSuggestionHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_suggestion_histories do |t|
      t.references :prompt, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :suggested_tags, null: false
      t.datetime :suggested_at, null: false
      t.integer :rating, default: 0
      t.text :feedback

      t.timestamps
    end
    
    add_index :tag_suggestion_histories, [:prompt_id, :suggested_at]
  end
end 