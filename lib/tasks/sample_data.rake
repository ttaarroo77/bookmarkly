namespace :db do
  desc "クラウドソーシング関連のサンプルタグを追加"
  task add_sample_tags: :environment do
    # 管理者ユーザーが存在しない場合は作成
    admin_user = User.find_by(email: 'admin@example.com')
    unless admin_user
      admin_user = User.create!(
        name: 'Admin User',
        email: 'admin@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      puts "管理者ユーザーを作成しました: #{admin_user.email}"
    else
      puts "既存の管理者ユーザーを使用します: #{admin_user.email}"
    end

    # クラウドソーシング関連のサンプルタグ
    sample_tags = [
      { name: 'ココナラ' },
      { name: 'ランサーズ' },
      { name: 'クラウドワークス' },
      { name: 'ライティング' },
      { name: '翻訳' },
      { name: 'イラスト生成' },
      { name: 'プログラミング' },
      { name: 'データ分析' },
      { name: '営業文書' },
      { name: '高単価案件' }
    ]

    # タグを登録
    sample_tags.each do |tag_data|
      tag = Tag.find_or_initialize_by(name: tag_data[:name], user_id: admin_user.id)
      
      if tag.save
        puts "タグを登録しました: #{tag.name}"
      else
        puts "タグの登録に失敗しました: #{tag.name}, エラー: #{tag.errors.full_messages.join(', ')}"
      end
    end

    puts "サンプルタグの登録が完了しました。合計: #{Tag.count}件"
  end
end 