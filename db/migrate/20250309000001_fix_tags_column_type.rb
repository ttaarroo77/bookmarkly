class FixTagsColumnType < ActiveRecord::Migration[8.0]
  def up
    # 既存のtagsカラムを一時的なカラムにコピー
    add_column :bookmarks, :tags_temp, :text
    
    # データを移行
    Bookmark.find_each do |bookmark|
      bookmark.update_column(:tags_temp, bookmark.tags.to_json)
    end
    
    # 既存のカラムを削除して新しいカラムを作成
    remove_column :bookmarks, :tags
    add_column :bookmarks, :tags, :text, array: true, default: []
    
    # データを戻す
    Bookmark.find_each do |bookmark|
      tags_array = JSON.parse(bookmark.tags_temp) rescue []
      bookmark.update_column(:tags, tags_array)
    end
    
    # 一時カラムを削除
    remove_column :bookmarks, :tags_temp
  end
  
  def down
    # ロールバック処理（必要に応じて実装）
  end
end 