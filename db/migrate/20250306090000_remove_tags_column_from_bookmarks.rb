class RemoveTagsColumnFromBookmarks < ActiveRecord::Migration[8.0]
  def change
    remove_column :bookmarks, :tags if column_exists?(:bookmarks, :tags)
  end
end 