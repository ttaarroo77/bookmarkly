# db/migrate/20250311081451_add_description_to_tags.rb - タグ説明追加
  

class AddDescriptionToTags < ActiveRecord::Migration[8.0]
  def change
    add_column :tags, :description, :text
  end
end
