# db/migrate/20250310000002_create_new_tags.rb - タグテーブル作成

class CreateNewTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    # 一意性制約を追加
    add_index :tags, [:name, :user_id], unique: true

    create_table :prompts_tags, id: false do |t|
      t.references :prompt, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
    end

    # 中間テーブルにも一意性制約を追加
    add_index :prompts_tags, [:prompt_id, :tag_id], unique: true
  end
end 