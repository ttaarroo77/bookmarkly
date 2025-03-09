class EnsureTagsColumnForPrompts < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:prompts, :tags)
      add_column :prompts, :tags, :text, default: '[]'
    end
  end
end 