class AddStatusToPrompts < ActiveRecord::Migration[8.0]
  def change
    add_column :prompts, :ai_processing_status, :integer, default: 0
    add_column :prompts, :ai_processed_at, :datetime
  end
end 