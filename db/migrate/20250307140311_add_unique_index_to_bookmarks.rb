class AddUniqueIndexToBookmarks < ActiveRecord::Migration[8.0]
  def change
    # 既存の重複データがある場合は事前にクリーンアップが必要
    remove_index :bookmarks, [:url, :user_id] if index_exists?(:bookmarks, [:url, :user_id])
    add_index :bookmarks, [:url, :user_id], unique: true, name: 'index_bookmarks_on_url_and_user_id'
  end
end 