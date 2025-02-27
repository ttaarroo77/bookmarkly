class AddDescriptionToBookmarks < ActiveRecord::Migration[7.0]
  def change
    # add_column :bookmarks, :description, :text
    add_column :bookmarks, :ai_processing_status, :integer, default: 0
    add_column :bookmarks, :ai_processed_at, :datetime
  end
end 