class RemoveTagsArrayFromPrompts < ActiveRecord::Migration[7.1]
  def up
    # 既存のデータを中間テーブルに移行（必要に応じて）
    Prompt.find_each do |prompt|
      if prompt.respond_to?(:tags_array) && prompt.tags_array.present?
        prompt.tags_array.each do |tag_name|
          next if tag_name.blank?
          tag = Tag.find_or_create_by(name: tag_name.downcase, user_id: prompt.user_id)
          prompt.tags << tag unless prompt.tags.include?(tag)
        end
      end
    end

    # 配列型tagsカラムを削除
    remove_column :prompts, :tags, :text, array: true, default: [], if_exists: true
  end

  def down
    # 配列型tagsカラムを復元
    add_column :prompts, :tags, :string, array: true, default: []
    
    # 中間テーブルのデータを配列型カラムに移行
    Prompt.find_each do |prompt|
      prompt.update_column(:tags, prompt.tags.pluck(:name))
    end
  end
end 