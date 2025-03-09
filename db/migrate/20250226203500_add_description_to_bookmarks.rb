class AddDescriptionToPrompts < ActiveRecord::Migration[7.0]
  def change
    add_column :prompts, :description, :text
    add_column :prompts, :ai_processing_status, :integer, default: 0
    add_column :prompts, :ai_processed_at, :datetime
  end
end 