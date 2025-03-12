class AiTagSuggester
  require 'openai'
  require 'httparty'
  require 'nokogiri'

  def initialize(user)
    @user = user
  end

  # URLからタグを提案
  def suggest_tags_for_url(url)
    return [] if url.blank?

    # URLからコンテンツを取得
    content = fetch_url_content(url)
    return [] if content.blank?

    # 既存のタグを取得（ユーザーコンテキスト）
    existing_tags = @user.tags.pluck(:name)

    # OpenAI APIにリクエスト
    response = openai_request(url, content, existing_tags)
    
    # レスポンスからタグを抽出
    parse_tags_from_response(response)
  end

  # 複合情報からタグを提案（URL、タイトル、説明文を考慮）
  def suggest_tags_for_prompt(prompt)
    # モックモードの場合はモックタグを返す
    if ENV['MOCK_AI'] == 'true'
      Rails.logger.debug "Using mock tags due to MOCK_AI=true"
      return mock_tags
    end
    
    # 基本的なタグ候補を取得
    tag_suggestions = []
    
    # APIからタグ候補を取得
    api_tags = get_tags_from_api(prompt)
    tag_suggestions.concat(api_tags) if api_tags.present?
    
    # 既存のDBから関連タグを取得
    db_tags = get_related_tags_from_db(prompt)
    
    # 既存タグと新規タグを組み合わせて返す
    combined_tags = combine_and_rank_tags(api_tags, db_tags)
    
    # 最大10個のタグに制限
    combined_tags.take(10)
  end

  private

  def fetch_url_content(url)
    begin
      response = HTTParty.get(url, timeout: 10)
      if response.success?
        doc = Nokogiri::HTML(response.body)
        
        # メタデータとコンテンツを抽出
        title = doc.at('title')&.text || ''
        description = doc.at('meta[name="description"]')&.[]('content') || ''
        keywords = doc.at('meta[name="keywords"]')&.[]('content') || ''
        
        # 本文からテキストを抽出（最初の1000文字程度）
        body_text = doc.css('body').text.gsub(/\s+/, ' ').strip[0...1000]
        
        # 重要な情報を組み合わせる
        [title, description, keywords, body_text].join(' ')
      else
        Rails.logger.error "Failed to fetch URL: #{url}, status: #{response.code}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching URL: #{url}, error: #{e.message}"
      nil
    end
  end

  def openai_request(url, content, existing_tags)
    client = OpenAI::Client.new
    
    client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: "URL: #{url}\n\n既存のタグ: #{existing_tags.join(', ')}\n\nコンテンツ: #{content}" }
        ]
      }
    )
  end

  def openai_request_with_context(prompt_info, content, existing_tags)
    begin
      # APIキーを明示的に指定
      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      
      # APIキーが設定されているかログに出力
      Rails.logger.info "OpenAI API Key設定状況: #{ENV['OPENAI_API_KEY'].present? ? '設定済み' : '未設定'}"
      
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: <<~PROMPT
              以下の情報に基づいて、最適なタグを提案してください。
              
              URL: #{prompt_info[:url]}
              タイトル: #{prompt_info[:title]}
              説明: #{prompt_info[:description]}
              
              既存のタグ: #{existing_tags.join(', ')}
              
              URLのコンテンツ: #{content}
              
              ユーザーが過去に使用したタグを優先的に提案し、新しいタグも適切であれば提案してください。
            PROMPT
            }
          ]
        }
      )
    rescue => e
      Rails.logger.error "Error in openai_request_with_context: #{e.message}"
      []
    end
  end

  def system_prompt
    <<~PROMPT
      あなたはプロンプト管理アプリのタグ提案AIです。
      URLのコンテンツを分析して、そのコンテンツに最も適したタグを5つまで提案してください。
      
      タグは、コンテンツの主題やトピック、技術、概念などを反映する簡潔な単語やフレーズにしてください。
      
      各タグには0-100の関連度スコアを付けてください。
      
      ユーザーが過去に使用したタグがある場合は、それらを優先的に提案してください。
      ただし、コンテンツに関連性がない場合は、新しいタグを提案してください。
      
      以下のフォーマットでJSONで回答してください:
      ```json
      [
        {"tag": "タグ名1", "score": 95, "is_new": false},
        {"tag": "タグ名2", "score": 85, "is_new": true},
        ...
      ]
      ```
      
      is_newフィールドは、そのタグがユーザーの既存タグにない場合はtrue、ある場合はfalseにしてください。
    PROMPT
  end

  def parse_tags_from_response(response)
    content = response.dig("choices", 0, "message", "content")
    return [] if content.blank?

    # JSONを抽出
    json_match = content.match(/```json\n(.*?)\n```/m)
    json_str = json_match ? json_match[1] : content

    # JSONをパース
    begin
      result = JSON.parse(json_str)
      result
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse JSON from OpenAI response: #{e.message}"
      []
    end
  end

  def mock_tags
    Rails.logger.debug "Generating mock tags"
    [
      {"tag" => "モックタグ1", "score" => 95, "is_new" => false},
      {"tag" => "モックタグ2", "score" => 85, "is_new" => true},
      {"tag" => "モックタグ3", "score" => 75, "is_new" => true}
    ]
  end

  # DBから関連タグを取得
  def get_related_tags_from_db(prompt)
    return [] unless @user && prompt.title.present?
    
    # タイトルとURLから関連するタグを検索
    keywords = extract_keywords(prompt.title, prompt.description)
    
    related_tags = []
    
    # キーワードに基づいて関連タグを検索
    keywords.each do |keyword|
      # ユーザーの既存タグから類似したものを検索
      @user.tags.each do |tag|
        similarity = calculate_similarity(keyword, tag.name)
        if similarity > 0.5 # 類似度が50%以上
          related_tags << {
            "tag" => tag.name,
            "score" => (similarity * 100).to_i,
            "is_new" => false
          }
        end
      end
    end
    
    # スコア順にソート
    related_tags.sort_by { |tag| -tag["score"] }.uniq { |tag| tag["tag"] }
  end

  # キーワード抽出（簡易版）
  def extract_keywords(title, description)
    text = "#{title} #{description}"
    # 単語を分割して、3文字以上のものを抽出
    words = text.scan(/\w+/).select { |word| word.length >= 3 }
    words.uniq
  end

  # 文字列の類似度計算（レーベンシュタイン距離の簡易実装）
  def calculate_similarity(str1, str2)
    return 0 if str1.blank? || str2.blank?
    
    # 大文字小文字を無視
    s1 = str1.downcase
    s2 = str2.downcase
    
    # 完全一致なら1.0
    return 1.0 if s1 == s2
    
    # 部分一致の場合は部分的な類似度を返す
    return 0.8 if s1.include?(s2) || s2.include?(s1)
    
    # 先頭一致の場合
    return 0.7 if s1.start_with?(s2) || s2.start_with?(s1)
    
    # 簡易的な類似度計算
    common_chars = (s1.chars & s2.chars).length.to_f
    total_chars = (s1.length + s2.length) / 2.0
    
    common_chars / total_chars
  end

  # APIタグと既存タグを組み合わせてランク付け
  def combine_and_rank_tags(api_tags, db_tags)
    combined = []
    
    # APIタグを追加
    api_tags.each do |tag|
      combined << tag
    end
    
    # DBタグを追加（重複を避ける）
    db_tags.each do |db_tag|
      # 既に同じタグが存在するか確認
      existing = combined.find { |t| t["tag"].downcase == db_tag["tag"].downcase }
      
      if existing
        # スコアが高い方を採用
        existing["score"] = [existing["score"], db_tag["score"]].max
      else
        combined << db_tag
      end
    end
    
    # スコア順にソート
    combined.sort_by { |tag| -tag["score"] }
  end
end 