class DropTagsTables < ActiveRecord::Migration[7.0]
  def up
    # 外部キー制約を確認して削除
    if table_exists?(:prompt_tags)
      remove_foreign_key :prompt_tags, :tags if foreign_key_exists?(:prompt_tags, :tags)
      drop_table :prompt_tags
    end
    
    # 中間テーブルがある場合は先に削除
    if table_exists?(:prompts_tags)
      drop_table :prompts_tags
    end
    
    # タグテーブルを削除
    if table_exists?(:tags)
      drop_table :tags
    end
  end

  def down
    # ロールバック時の処理（必要に応じて実装）
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :prompts_tags, id: false do |t|
      t.belongs_to :prompt
      t.belongs_to :tag
    end
  end
  
  private
  
  def foreign_key_exists?(table, reference)
    foreign_keys = connection.foreign_keys(table.to_s)
    foreign_keys.any? { |fk| fk.to_table.to_s == reference.to_s }
  end
end 