# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# デフォルトユーザーの取得（既に存在する場合）または作成
default_user = User.find_by(email: 'test@example.com')
if default_user.nil?
  default_user = User.create!(
    name: 'テストユーザー',
    email: 'test@example.com',
    password: 'password',
    password_confirmation: 'password'
  )
end

# タグのカテゴリとデータを定義
tag_categories = {
  'サービス' => [
    'ライティング',
    'コピーライティング',
    'ブログ記事',
    'SNS投稿',
    'メルマガ',
    '商品説明'
  ],
  '文章種類' => [
    '紹介文',
    'プロフィール',
    'セールスレター',
    '企画書',
    '提案書'
  ],
  '文体' => [
    'フレンドリー',
    'ビジネス',
    'カジュアル',
    '専門的',
    '説得力'
  ],
  '業界' => [
    'IT',
    '美容',
    '健康',
    '教育',
    '不動産',
    '金融'
  ],
  '目的' => [
    '集客',
    'コンバージョン',
    'ブランディング',
    'リピーター獲得'
  ],
  'AIツール' => [
    'ChatGPT',
    'Claude',
    'Gemini'
  ],
  '特徴' => [
    '高単価',
    '初心者向け',
    '効率化',
    'テンプレート'
  ]
}

# 既存のタグを全て削除（オプション）
Tag.destroy_all

# デフォルトユーザーのタグを作成
tag_categories.each do |category, tags|
  tags.each do |tag_name|
    # タグの説明文を設定
    description = "#{category}カテゴリの#{tag_name}に関するプロンプト"
    
    # タグを作成
    default_user.tags.create!(
      name: tag_name,
      description: description
    )
  end
end

puts "タグの初期データを作成しました。"
