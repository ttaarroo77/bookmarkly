namespace :db do
  desc "データベースの整合性をチェックして修正する"
  task cleanup: :environment do
    puts "タグテーブルの確認..."
    tags = ActiveRecord::Base.connection.execute("SELECT * FROM tags;")
    puts "タグ数: #{tags.count}"
    
    puts "prompts_tagsテーブルの確認..."
    prompts_tags = ActiveRecord::Base.connection.execute("SELECT * FROM prompts_tags;")
    puts "関連付け数: #{prompts_tags.count}"
    
    puts "不整合データの確認..."
    inconsistencies = ActiveRecord::Base.connection.execute("SELECT pt.* FROM prompts_tags pt LEFT JOIN tags t ON pt.tag_id = t.id WHERE t.id IS NULL;")
    puts "不整合データ数: #{inconsistencies.count}"
    
    if inconsistencies.count > 0
      puts "不整合データを削除しています..."
      deleted = ActiveRecord::Base.connection.execute("DELETE FROM prompts_tags WHERE tag_id NOT IN (SELECT id FROM tags);")
      puts "削除完了"
    else
      puts "不整合データはありません"
    end
    
    # 未使用タグの削除
    puts "未使用タグの確認..."
    Tag.cleanup_unused_tags
    puts "未使用タグの削除完了"
  end
end 