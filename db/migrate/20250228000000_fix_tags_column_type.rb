class FixTagsColumnType < ActiveRecord::Migration[8.0]
  def up
    # 既存のtagsカラムの型を確認
    connection.execute("SELECT pg_typeof(tags) FROM bookmarks LIMIT 1").each do |row|
      if row['pg_typeof'] != 'text[]'
        # 一時的なカラムを作成
        add_column :bookmarks, :tags_array, :text, array: true, default: []
        
        # データを移行（文字列からの変換）
        execute <<-SQL
          UPDATE bookmarks 
          SET tags_array = string_to_array(tags, ',')
          WHERE tags IS NOT NULL
        SQL
        
        # 古いカラムを削除
        remove_column :bookmarks, :tags
        
        # 新しいカラムの名前を変更
        rename_column :bookmarks, :tags_array, :tags
        
        # インデックスを追加（オプション）
        add_index :bookmarks, :tags, using: 'gin'
      end
    end
  end
  
  def down
    # ロールバック処理（必要に応じて実装）
  end
end 