class FixTagsColumnType < ActiveRecord::Migration[8.0]
  def up
    # 既存のtagsカラムを一時的なカラムにコピー
    add_column :prompts, :tags_temp, :text
    
    # データを移行
    Prompt.find_each do |prompt|
      prompt.update_column(:tags_temp, prompt.tags.to_json)
    end
    
    # 既存のカラムを削除して新しいカラムを作成
    remove_column :prompts, :tags
    add_column :prompts, :tags, :text, array: true, default: []
    
    # データを戻す
    Prompt.find_each do |prompt|
      tags_array = JSON.parse(prompt.tags_temp) rescue []
      prompt.update_column(:tags, tags_array)
    end
    
    # 一時カラムを削除
    remove_column :prompts, :tags_temp
  end
  
  def down
    # ロールバック処理（必要に応じて実装）
  end
end 