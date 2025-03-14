# db/migrate/20250311050344_add_indexes_to_tags_and_prompts_tags.rb - タグインデックス追加

   
   class AddIndexesToTagsAndPromptsTags < ActiveRecord::Migration[7.0]
    def change
      # タグ名とユーザーIDの組み合わせに一意性制約を追加
      add_index :tags, [:name, :user_id], unique: true, if_not_exists: true
      
      # prompts_tagsテーブルに複合インデックスを追加
      add_index :prompts_tags, [:prompt_id, :tag_id], unique: true, if_not_exists: true
      
      # 不整合データの修正
      reversible do |dir|
        dir.up do
          # 不整合データの確認と削除
          inconsistencies = execute("SELECT pt.* FROM prompts_tags pt LEFT JOIN tags t ON pt.tag_id = t.id WHERE t.id IS NULL;")
          if inconsistencies.count > 0
            puts "#{inconsistencies.count}件の不整合データを削除します"
            execute("DELETE FROM prompts_tags WHERE tag_id NOT IN (SELECT id FROM tags);")
          end
        end
      end
    end
  end