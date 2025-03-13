class TagSuggestionService
  # モックモードかどうかを確認
  def self.mock_mode?
    ENV.fetch("MOCK_AI", "false") == "true" || ENV["OPENAI_API_KEY"].blank?
  end
  
  # プロンプトからタグを提案
  def self.suggest_tags(prompt)
    # モックモードの場合はダミーデータを返す
    return mock_tags(prompt) if mock_mode?
    
    begin
      # OpenAI APIを使用してタグを生成
      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
      
      # プロンプトの情報を整形
      content = "以下のWebページに適したタグを5つ程度、カンマ区切りで提案してください。タグは単語または短いフレーズにしてください。\n\n"
      content += "タイトル: #{prompt.title}\n"
      content += "URL: #{prompt.url}\n"
      content += "説明: #{prompt.description}" if prompt.description.present?
      
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "あなたはWebページの内容を分析し、適切なタグを提案するAIアシスタントです。" },
            { role: "user", content: content }
          ],
          temperature: 0.7,
        }
      )
      
      # レスポンスからタグを抽出
      response.dig("choices", 0, "message", "content")
    rescue => e
      Rails.logger.error "Error in TagSuggestionService: #{e.message}"
      # エラー時はモックタグを返す
      mock_tags(prompt)
    end
  end
  
  private
  
  # APIキーが設定されているか確認
  def self.api_key_present?
    ENV['OPENAI_API_KEY'].present?
  end
  
  # モックタグを生成（開発環境用）
  def self.generate_mock_tags(prompt)
    # プロンプトのタイトルと説明文から単語を抽出
    title_words = prompt.title.downcase.gsub(/[^\p{L}\s]/u, ' ').split.uniq
    description_words = prompt.description.present? ? 
                         prompt.description.downcase.gsub(/[^\p{L}\s]/u, ' ').split.uniq : []
    
    # 一般的なプログラミング関連タグ
    base_tags = ['Rails', 'Ruby', 'プログラミング', 'チュートリアル', 'API', 
                'JavaScript', 'フロントエンド', 'バックエンド', '開発', '技術記事']
    
    # タイトルと説明文の単語に基づいてタグを選択
    matched_tags = base_tags.select do |tag| 
      tag_lower = tag.downcase
      title_words.any? { |word| word.include?(tag_lower) || tag_lower.include?(word) } ||
      description_words.any? { |word| word.include?(tag_lower) || tag_lower.include?(word) }
    end
    
    # マッチしたタグと基本タグをランダムに組み合わせて最大5つのタグを返す
    result = matched_tags.take(3)
    result += base_tags.sample(5 - result.size) if result.size < 5
    
    # カンマ区切りの文字列に変換
    result.join(', ')
  end
  
  # OpenAI APIを使用してタグを生成（本番環境用）
  def self.generate_ai_tags(prompt)
    require 'net/http'
    require 'uri'
    require 'json'
    
    # APIキーの取得
    api_key = ENV['OPENAI_API_KEY']
    return generate_mock_tags(prompt) unless api_key.present?
    
    begin
      # OpenAI APIのエンドポイント
      uri = URI.parse('https://api.openai.com/v1/chat/completions')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      # リクエストの準備
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_key}"
      
      # プロンプトの内容を用意
      content = "以下のウェブコンテンツに適したタグを5つ提案してください。タグはカンマ区切りで返してください。\n\n"
      content += "タイトル: #{prompt.title}\n"
      content += "URL: #{prompt.url}\n"
      content += "説明: #{prompt.description}\n\n"
      content += "タグの例: Rails, Ruby, プログラミング, チュートリアル, AI, API, JavaScript, フロントエンド, バックエンド, 開発, 技術記事\n"
      content += "フォーマット: タグ1, タグ2, タグ3, タグ4, タグ5"
      
      # リクエストボディの作成
      request.body = {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "あなたはタグ提案の専門家です。与えられたコンテンツに最適なタグを提案してください。" },
          { role: "user", content: content }
        ],
        max_tokens: 150,
        temperature: 0.7
      }.to_json
      
      # APIリクエストの送信
      response = http.request(request)
      
      # レスポンスの解析
      if response.code == '200'
        result = JSON.parse(response.body)
        tags = result['choices'][0]['message']['content'].strip
        
        # レスポンスから不要な部分を削除して整形
        tags = tags.gsub(/^タグ：|^タグ:|^Tags:|^タグ：\s*/, '')
        
        # 正規表現でタグを抽出
        if tags =~ /^[\p{L}\p{N}\s\-_,]+$/u
          return tags
        else
          # フォーマットが不適切な場合はモックタグを返す
          Rails.logger.error "Invalid tags format received from OpenAI: #{tags}"
          return generate_mock_tags(prompt)
        end
      else
        # APIエラーの場合はモックタグを返す
        Rails.logger.error "OpenAI API error: #{response.code} - #{response.body}"
        return generate_mock_tags(prompt)
      end
    rescue => e
      # 例外発生時はモックタグを返す
      Rails.logger.error "Error calling OpenAI API: #{e.message}"
      return generate_mock_tags(prompt)
    end
  end
  
  def self.mock_tags(prompt)
    # タイトルと説明から簡易的にタグを生成
    title = prompt.title.to_s.downcase
    description = prompt.description.to_s.downcase
    
    tags = []
    
    # プログラミング言語関連
    tags << "Ruby" if title.include?("ruby") || description.include?("ruby")
    tags << "JavaScript" if title.include?("javascript") || description.include?("javascript") || title.include?("js")
    tags << "Python" if title.include?("python") || description.include?("python")
    
    # フレームワーク関連
    tags << "Rails" if title.include?("rails") || description.include?("rails")
    tags << "React" if title.include?("react") || description.include?("react")
    
    # 一般的なタグ
    tags << "プログラミング" if title.include?("プログラミング") || description.include?("プログラミング") || 
                            title.include?("programming") || description.include?("programming")
    tags << "API" if title.include?("api") || description.include?("api")
    tags << "技術記事" if title.include?("技術") || description.include?("技術") || 
                       title.include?("tech") || description.include?("tech")
    
    # タグが少ない場合は汎用的なタグを追加
    if tags.size < 3
      tags << "Web開発" unless tags.include?("Web開発")
      tags << "チュートリアル" unless tags.include?("チュートリアル")
      tags << "参考資料" unless tags.include?("参考資料")
    end
    
    # 最大5つのタグを返す
    tags.uniq.take(5).join(", ")
  end
end 