namespace :debug do
  desc "タグ候補生成のテスト"
  task test_tag_suggestions: :environment do
    if User.count == 0
      puts "ユーザーが存在しません。テストを実行できません。"
      exit
    end
    
    user = User.first
    puts "ユーザー: #{user.email}"
    
    if user.prompts.count == 0
      puts "プロンプトが存在しません。テストを実行できません。"
      exit
    end
    
    prompt = user.prompts.first
    puts "プロンプト: #{prompt.title} (#{prompt.url})"
    
    puts "環境変数:"
    puts "MOCK_AI: #{ENV['MOCK_AI']}"
    puts "OPENAI_API_KEY設定: #{ENV['OPENAI_API_KEY'].present? ? '設定済み' : '未設定'}"
    
    puts "\nタグ候補を生成中..."
    suggester = AiTagSuggester.new(user)
    
    # モックモードでのテスト
    ENV['MOCK_AI'] = 'true'
    puts "\n--- モックモードでのテスト ---"
    mock_suggestions = suggester.suggest_tags_for_prompt(prompt)
    puts "モックタグ候補: #{mock_suggestions.inspect}"
    
    # 実際のAPIでのテスト
    ENV['MOCK_AI'] = 'false'
    puts "\n--- 実際のAPIでのテスト ---"
    begin
      api_suggestions = suggester.suggest_tags_for_prompt(prompt)
      puts "API タグ候補: #{api_suggestions.inspect}"
    rescue => e
      puts "APIエラー: #{e.message}"
    end
    
    # 環境変数を元に戻す
    ENV['MOCK_AI'] = 'true'
  end
end 