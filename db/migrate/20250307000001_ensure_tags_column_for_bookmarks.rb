class EnsureTagsColumnForBookmarks < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:bookmarks, :tags)
      add_column :bookmarks, :tags, :text, default: '[]'
    end
  end
end 