# 20250307140311_add_unique_index_to_prompts.rb - ユニークインデックス追加


class AddUniqueIndexToPrompts < ActiveRecord::Migration[8.0]
  def change
    # 既存の重複データがある場合は事前にクリーンアップが必要
    remove_index :prompts, [:url, :user_id] if index_exists?(:prompts, [:url, :user_id])
    add_index :prompts, [:url, :user_id], unique: true, name: 'index_prompts_on_url_and_user_id'
  end
end 