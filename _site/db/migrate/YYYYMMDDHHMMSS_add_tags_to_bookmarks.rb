class AddTagsToBookmarks < ActiveRecord::Migration[7.0]
  def up
    # 既存のtagsカラムを削除（もし存在する場合）
    remove_column :bookmarks, :tags if column_exists?(:bookmarks, :tags)
    
    # 配列型のtagsカラムを追加
    add_column :bookmarks, :tags, :string, array: true, default: []
    
    # インデックスを追加してパフォーマンスを向上
    add_index :bookmarks, :tags, using: 'gin'
  end

  def down
    remove_index :bookmarks, :tags
    remove_column :bookmarks, :tags
  end
end 