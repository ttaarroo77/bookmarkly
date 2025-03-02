namespace :bookmarks do
  desc "タグデータのクリーンアップ"
  task cleanup_tags: :environment do
    Bookmark.find_each do |bookmark|
      if bookmark.tags.present?
        # 現在のタグを取得
        current_tags = bookmark.tags
        
        # タグをクリーンアップ
        cleaned_tags = current_tags.map do |tag|
          if tag.is_a?(String)
            # 引用符や括弧を削除
            tag.gsub(/^\[|\]$/, '').gsub(/^"|"$/, '').gsub(/\\"/, '"').strip
          else
            tag.to_s
          end
        end.reject(&:empty?).uniq
        
        # クリーンアップされたタグが異なる場合のみ更新
        if cleaned_tags != current_tags
          bookmark.update_column(:tags, cleaned_tags)
          puts "Bookmark ID: #{bookmark.id} のタグを更新しました: #{current_tags.inspect} -> #{cleaned_tags.inspect}"
        end
      end
    end
    
    puts "タグのクリーンアップが完了しました。"
  end
end 