# 20240316000001_create_tag_suggestions.rb - タグ候補テーブル作成


class CreateTagSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_suggestions do |t|
      t.references :prompt, null: false, foreign_key: true
      t.string :name, null: false
      t.float :confidence
      t.boolean :applied, default: false

      t.timestamps
    end

    add_index :tag_suggestions, [:prompt_id, :name], unique: true
  end
end