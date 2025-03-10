class RenameBookmarksToPrompts < ActiveRecord::Migration[7.0]
  def change
    rename_table :bookmarks, :prompts
  end
end 