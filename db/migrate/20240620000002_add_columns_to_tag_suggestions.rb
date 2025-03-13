class AddColumnsToTagSuggestions < ActiveRecord::Migration[6.1]
  def change
    # confidenceカラムが存在しない場合のみ追加
    unless column_exists?(:tag_suggestions, :confidence)
      add_column :tag_suggestions, :confidence, :float, default: 0.0
    end
    
    # appliedカラムが存在しない場合のみ追加
    unless column_exists?(:tag_suggestions, :applied)
      add_column :tag_suggestions, :applied, :boolean, default: false
    end
    
    # インデックスが存在しない場合のみ追加
    unless index_exists?(:tag_suggestions, [:prompt_id, :name])
      add_index :tag_suggestions, [:prompt_id, :name], unique: true
    end
  end
end 